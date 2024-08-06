import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/pages/Quiz/QuizPage.dart';
import 'package:easy_localization/easy_localization.dart';
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
            const Text("Congrantulations! You have completed the Quiz").tr(),
            Text("${"You have".tr()} ${correctAnswers} ${"answers of 5".tr()}"),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/quiz/introduction',
                  arguments: topic
                );
              },
              child: Text("Take another quiz").tr(),
            ),
            TextButton(
              onPressed:() {
                Navigator.pushNamed(context, '/detail', arguments: topic);
              },
              child: Text("Exit").tr(),
            ),
          ],
        ),
      ),
    );
  }
}