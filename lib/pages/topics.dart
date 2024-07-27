import 'package:flutter/material.dart';
import 'package:app_gemini/main.dart';
import 'package:app_gemini/pages/home.dart';
class Topicspage extends StatefulWidget {
  const Topicspage({Key? key}) : super(key: key);

  @override
  _TopicspageState createState() => _TopicspageState();
}

class _TopicspageState extends State<Topicspage> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Center(
        child: ListView.builder(
          itemCount: datos.length,
          itemBuilder: (context, index) {
            final topic = datos[index];
            return InkWell(
              onTap: () => _navigateToDetailScreen(datos[index]),
     
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  datos[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            );
          },
        ),
      ),
    );
    
  }
    void _navigateToDetailScreen(String dato) {
    Navigator.pushNamed(context, '/detail', arguments: dato);
  }
}


