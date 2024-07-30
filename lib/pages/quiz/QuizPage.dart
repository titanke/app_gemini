import 'package:app_gemini/interfaces/QuestionInterface.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/pages/Quiz/QuizPage.dart';
import 'package:app_gemini/services/Gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class QuizPage extends StatefulWidget {

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentStep = 0;
  bool _isCorrect = false;
  String? _selectedOption; 
  bool _optionSelected = false;
  int correctAnswers = 0;
  String? _answerText;
  bool _answerSubmitted = false;
  bool _showResult = false;
  bool _hasSubmitted = false;
  String _feedbackMessage = "";
  List<Question> _questions = [];
  GeminiService gem = GeminiService();
  late Topic topic;

  void _answerSelected(String? value) {
    setState(() {
      _selectedOption = value;
      _isCorrect = value == _questions[_currentStep].correctAnswer;
      _optionSelected = true;
      _answerSubmitted = true;


      if (value == _questions[_currentStep].correctAnswer) {
        _questions[_currentStep].isCompleted = true;
      }
      if (_isCorrect) {
        _feedbackMessage = '¡Correcto!';
      } else {
        _feedbackMessage = 'Incorrecto. La respuesta correcta es: ${_questions[_currentStep].correctAnswer}';
      }
    });
  }

  void _nextQuestion() async {
    if (_answerSubmitted) {
      if (_questions[_currentStep].type=='open') {
        bool response = false;//await gem.evaluateAnswer(_answerText!);
        setState(() {
          _isCorrect = response;
          _showResult = false;
        });
      } else {
        _isCorrect = _answerText == _questions[_currentStep].correctAnswer; // Local evaluation
      }

      setState(() {
        _questions[_currentStep].isCompleted = true;
        if (_currentStep < _questions.length - 1) {
          _currentStep++;
        } else {

          Navigator.pushNamed(
            context,
            '/quiz/result',
            arguments: {
              'correctAnswers':correctAnswers,
              'topic': topic,
            },
          );
        }
        _answerText = null;
        _answerSubmitted = false;
      });
      correctAnswers += _isCorrect ? 1 : 0;
    }
  }

  void _answerSubmittedCallback(String answer) {
    setState(() {
      _answerText = answer;
      _answerSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    //_questions = ModalRoute.of(context)!.settings.arguments as List<Question>;
    final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    _questions = args['questions'];
    topic = args['topic'] as Topic;


    return Scaffold(
      appBar: AppBar(title: Text('${topic.name}')),
      body: Stepper(
        controlsBuilder: (BuildContext context, ControlsDetails controls) {
        return SizedBox.shrink();
        },
        type: StepperType.horizontal,
        currentStep: _currentStep,

        onStepTapped: (step) {
          if (step == _currentStep + 1 && _isCorrect && _optionSelected) {

            setState(() {
              _currentStep = step;
            });
          }
        },
        steps: _questions.map((question) {
          return Step(
            title: Text(''),
              state: question.isCompleted ? StepState.complete : StepState.disabled,

            content: Column(
              children: [
                Text(question.question),
                 _buildQuestion(question),
               _buildButton()
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuestion(Question question) {
    switch (question.type) {
      case 'multipleChoice':
        return Column(
          children: question.options!
              .map((option) => RadioListTile(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedOption,
                    onChanged: _hasSubmitted ? null : _answerSelected,
                  ))
              .toList(),
        );
      case "open":
        return TextField(
          onChanged: (value) => _answerSubmittedCallback(value),
          decoration: InputDecoration(hintText: 'Ingrese su respuesta'),
        );
      default:
        return Text('Tipo de pregunta no soportado');
    }
  }

  Widget _buildButton() {
    return ElevatedButton(
      onPressed: _answerSubmitted
          ? () {
              setState(() {
                _showResult = !_showResult;
                _hasSubmitted = !_hasSubmitted;

                if (_showResult) {
                              ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _isCorrect
                                ? '¡Respuesta correcta!'
                                : '¡Respuesta incorrecta!',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  _nextQuestion();
                }
              });
            }
          : null,
      child: Text(_showResult ? 'Siguiente' : 'Comprobar'),
    );
  }


}




