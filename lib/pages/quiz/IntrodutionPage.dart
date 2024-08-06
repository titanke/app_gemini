import 'package:app_gemini/global/common/toast.dart';
import 'package:app_gemini/interfaces/QuestionInterface.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/services/Gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/pages/DetailTopicPage.dart';

class QuizIntroduction extends StatefulWidget {
  @override
  _QuizIntroductionState createState() => _QuizIntroductionState();
}

class _QuizIntroductionState extends State<QuizIntroduction> {
  bool _isLoading = false;
  GeminiService gem = GeminiService();

  @override
  Widget build(BuildContext context) {
    final Topic topic = ModalRoute.of(context)?.settings.arguments as Topic;

    void _startQuiz() async {
      setState(() {
        _isLoading = true;
      });

      try {
        List<Question> _questions = await gem.generateQuestions(topic.uid);

        if (_questions.length>0){
          Navigator.pushNamed(
            context,
            '/quiz/start',
            arguments: {
              'topic': topic,
              'questions': _questions
            },
          );
        }else{
          showToast(message: 'Error al generar preguntas intentelo denuevo');
        }

      } catch (e) {
        print('Error generating questions: $e');

      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    return Scaffold(
      //appBar: AppBar(title: Text('Quiz Introduction')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Bienvenido! ¿Estás preparado para tu quiz?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startQuiz,
                  child: Text('Continuar'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                   Navigator.pushNamed(context, '/detail', arguments: topic);
                    
                       // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(topic: topic)));

                  },
                  child: Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
