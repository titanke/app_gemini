import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String dato = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Temas: $dato'),
        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              // Navigate to play screen, passing the dato
              Navigator.pushNamed(context, '/quiz', arguments: dato);
            },
          ),
          IconButton(
            icon: Icon(Icons.storage),
            onPressed: () {
              // Navigate to storage screen, passing the dato
              Navigator.pushNamed(context, '/storage', arguments: dato);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(dato),
      ),
    );
  }
}
