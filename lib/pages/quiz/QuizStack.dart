import 'package:app_gemini/interfaces/QuestionInterface.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/pages/Quiz/QuizPage.dart';
import 'package:app_gemini/pages/quiz/IntrodutionPage.dart';
import 'package:app_gemini/pages/quiz/ResultPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class QuizStack extends StatefulWidget {
  @override
  _QuizStack createState() => _QuizStack();
}

class _QuizStack extends State<QuizStack> {

  @override
  Widget build(BuildContext context) {
    final Topic topic = ModalRoute.of(context)?.settings.arguments as Topic;
    return QuizIntroduction();
  }
}
