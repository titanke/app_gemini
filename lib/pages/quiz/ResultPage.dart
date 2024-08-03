import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/pages/Quiz/QuizPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    int correctAnswers = args['correctAnswers'];
    Topic topic = args['topic'] as Topic;

    return Scaffold(
      //appBar: AppBar(title: Text('Resultados')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¡Felicidades! Has terminado el quiz.'),
            Text('Obtuviste ${correctAnswers} respuestas correctas de 5'),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/quiz/introduction',
                );
              },
              child: Text(''),
            ),
            TextButton(
              onPressed:() {
                Navigator.pushNamed(context, '/detail', arguments: topic);
              },
              child: Text('Salir'),
            ),
          ],
        ),
      ),
    );
  }
}