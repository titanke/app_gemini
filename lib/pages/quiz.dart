import 'package:flutter/material.dart';

class Quizpage extends StatefulWidget {
  @override
  _QuizpageState createState() => _QuizpageState();
}

class _QuizpageState extends State<Quizpage> {
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
              'preguntas',
              style: TextStyle(fontSize: 30),
            ),
            Text(
              'Esta es una pantalla simple.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
