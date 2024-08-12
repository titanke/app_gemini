import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
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
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";

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
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  void _toggleFavorite(String topicId) {
    final favoritesProvider =
    Provider.of<ThemeProvider>(context, listen: false);
    if (favoritesProvider.favoriteTopics.contains(topicId)) {
      favoritesProvider.removeFavoriteTopic(topicId);
    } else {
      favoritesProvider.addFavoriteTopic(topicId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // ignore: prefer_const_constructors
        title: Center(
          // ignore: prefer_const_constructors
          child: Text(
            'Topics',
            // ignore: prefer_const_constructors
            style: TextStyle(
              // color: Colors.white,
              fontSize: 20,
            ),
          ).tr(),
        ),
        backgroundColor: Color(
            0xFFFFA500),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSearchTextField(
            controller: _searchController,
            placeholder: "Search".tr() + "...",
            prefixIcon: Icon(CupertinoIcons.search, color: CupertinoColors.systemOrange),
            style: TextStyle(color: CupertinoColors.black),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Topic>>(
            stream: db.getTopicsUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("Don't have a topic?, add one").tr());
              }

              final List<Topic> topics = snapshot.data!;
              final filteredTopics = topics
                  .where((topic) => topic.name
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()))
                  .toList();

              return ListView.builder(
                itemCount: filteredTopics.length,
                itemBuilder: (context, index) {
                  final topic = filteredTopics[index];
                  final favoritesProvider = Provider.of<ThemeProvider>(context);
                  final isFavorite = favoritesProvider.favoriteTopics.contains(topic.uid);
                  return InkWell(
                    onTap: () => _navigateToDetailScreen(topic),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                           
                            Expanded(
                              child: Text(
                                topic.name,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            IconButton(
                                 icon: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.deepOrangeAccent : Colors.grey,
                                      ),
                                 onPressed: () {
                                  _toggleFavorite(topic.uid);

                                 },
                               ),
                               
                            PopupMenuButton<int>(
                              icon: Icon(Icons.more_vert),
                              onSelected: (value) {
                                switch (value) {
                                  case 0:
                                    _showEditModal(topic.uid, topic.name);
                                    break;
                                  case 1:
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
                                                db.DeleteTopic(topic.uid, context);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Remove").tr(),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                              
                                PopupMenuItem(
                                  value: 0,
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text("Edit").tr(),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete),
                                      SizedBox(width: 8),
                                      Text("Delete").tr(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );

            },
          ),
        ),
      ]),
    );
  }

  void _navigateToDetailScreen(Object topic) {
    Navigator.pushNamed(context, '/detail', arguments: topic);
  }

  void _showEditModal(String topicId, String currentName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Topic").tr(),
          content: Form(
            key: _formKey,
            child: TextFormField(
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
                db.EditTopic(topicId, _newTopicName, _formKey, context);
              },
              child: Text("Save").tr(),
            ),
          ],
        );
      },
    );
  }
}