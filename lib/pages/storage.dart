import 'package:flutter/material.dart';

class Storagepage extends StatefulWidget {
  @override
  _StoragepageState createState() => _StoragepageState();
}

class _StoragepageState extends State<Storagepage> {
  @override
  Widget build(BuildContext context) {
        final String dato = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
    appBar: AppBar(
        title: Text('Temas: $dato'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '¡chat',
              style: TextStyle(fontSize: 30),
            ),
            Text(
              'Esta es una pantalla storage.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
