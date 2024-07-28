import 'package:app_gemini/interfaces/topicInterface.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Topic dato = ModalRoute.of(context)?.settings.arguments as Topic;

    return Scaffold(
      appBar: AppBar(
        title: Text('Temas: ${dato.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.storage),
            onPressed: () {
              Navigator.pushNamed(context, '/storage', arguments: dato.uid);
            },
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.pushNamed(context, '/quiz', arguments: dato);
            },
          ),

        ],
      ),
      body: Center(
        child: Text(dato.name),
      ),
    );
  }
}
