import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app_gemini/widgets/theme_provider.dart';
import 'package:app_gemini/pages/DetailTopicPage.dart';

final List<String> favoriteTopics = []; 
class Topicspage extends StatefulWidget {
  const Topicspage({Key? key}) : super(key: key);

  @override
  _TopicspageState createState() => _TopicspageState();
}

class _TopicspageState extends State<Topicspage> {
  String _newTopicName = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final FirebaseDatabase db = FirebaseDatabase();
  Future<void> _loadFavoriteTopics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedFavorites = prefs.getStringList('favoriteTopics');
    if (savedFavorites != null) {
      setState(() {
        favoriteTopics.addAll(savedFavorites);
      });
    }
  }

  @override
    void initState() {
    super.initState();
    _loadFavoriteTopics();
  }

void _toggleFavorite(String topicId) {
  final favoritesProvider = Provider.of<ThemeProvider>(context, listen: false);
  if (favoritesProvider.favoriteTopics.contains(topicId)) {
    favoritesProvider.removeFavoriteTopic(topicId);
  } else {
    favoritesProvider.addFavoriteTopic(topicId);
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
    
      body: Column(

        children: [
    Expanded(
    child: StreamBuilder<List<Topic>>(
    stream: db.getTopicsUser(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) 
      {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text("Don't? have a topic, add one").tr());
      }

      final List<Topic> topics = snapshot.data!;

      return ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          final favoritesProvider = Provider.of<ThemeProvider>(context);
          final isFavorite = favoritesProvider.favoriteTopics.contains(topic.uid);
          return InkWell(
            onTap: () => _navigateToDetailScreen(topic),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: 
                  [
                  Expanded(child: Text(topic.name, 
                  style: const TextStyle(fontSize: 20))),
                      IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey, 

                  ),
                  onPressed: () => _toggleFavorite(topic.uid), 
                ),
                      IconButton(
                  icon: Icon(
                        Icons.edit
                  ),
                  onPressed: () => _showEditModal(topic.uid, topic.name) 
                ),
                 IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Are you sure?").tr(),
                          content: Text("This action will remove this topic permanently").tr(),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); 
                              },
                              child: Text("Cancel").tr(),
                            ),
                            TextButton(
                              onPressed: () {
                                db.DeleteTopic(topic.uid);
                                Navigator.of(context).pop(); 
                              },
                              child: Text("Remove").tr(),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ],
              ),
            ),
          );
        },
      );
    },
  ),
),
          ElevatedButton(
            onPressed: () => _showTemaModal(context),
            child:Text("Add Topic").tr(),
          ),
        ]
      ),
    );
    
  }
  void _navigateToDetailScreen(Object dato) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(topic: dato as Topic)));
  }

  void _guardarTema() async {
    if (_formKey.currentState!.validate()) {
          String name = _nameController.text;
          try {
            db.saveTopic(name); 
            _nameController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Topic succesfully saved").tr()),
            );
            Navigator.of(context).pop();
          } catch (e) {
            print("Error creating topic".tr());
          }      
    }
  }
  void _showTemaModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Topic Name").tr(),
        content: Form(
          key: _formKey,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a topic name".tr();
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarTema,
              child: Text("Save").tr(),
            ),
          ],
        ),
       )
      );
    },
  );
}
 void _showEditModal(String topicId, String currentName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Topic").tr(),
          
 content: Form(
          key: _formKey,
           child:          
           TextFormField(
            controller: TextEditingController(text: currentName),
             validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a topic name".tr();
                }
                return null;
              },
            decoration: InputDecoration(hintText: ''),
             onChanged: (value) {
              _newTopicName = value;
            },
          ),
          ),
                  actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel").tr(),
          ),
          TextButton(
            onPressed: () {
              db.EditTopic(topicId, _newTopicName,_formKey,context);
            },
            child: Text("Save").tr(),
          ),
        ],
        );
      },
    );
  }


}





