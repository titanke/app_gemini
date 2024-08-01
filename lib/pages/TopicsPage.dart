import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app_gemini/widgets/theme_provider.dart';

final List<String> favoriteTopics = []; 
class Topicspage extends StatefulWidget {
  const Topicspage({Key? key}) : super(key: key);

  @override
  _TopicspageState createState() => _TopicspageState();
}

class _TopicspageState extends State<Topicspage> {

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
 
  void _showTemaModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: TemaModal(),
        );
      },
    );
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
        return Center(child: Text('No tienes ningun tema, Agrega uno'));
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
            child: Text('Agregar Tema'),
          ),
        ]
      ),
    );
    
  }
    void _navigateToDetailScreen(Object dato) {
    Navigator.pushNamed(context, '/detail', arguments: dato);
  }
}


class TemaModal extends StatefulWidget {
  @override
  _TemaModalState createState() => _TemaModalState();
}

class _TemaModalState extends State<TemaModal> {

  final TextEditingController _nameController = TextEditingController();
  final FirebaseDatabase _db = FirebaseDatabase();

  void _guardarTema() async {
    String name = _nameController.text;
    try {
      _db.saveTopic(name);
    }catch(e){
      print("Error en crear el tema $e");
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarTema,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

