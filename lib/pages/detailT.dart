import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String dato = ModalRoute.of(context)?.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle: $dato'),
      ),
      body: Center(
        child: Text(dato),
      ),
    );
  }
}