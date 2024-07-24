import 'package:flutter/material.dart';



class Topicspage extends StatefulWidget {
  @override
  _TopicspageState createState() => _TopicspageState();
}

class _TopicspageState extends State<Topicspage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'topics',
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
