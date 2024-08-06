import 'package:app_gemini/interfaces/QuestionInterface.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/pages/Quiz/QuizPage.dart';
import 'package:app_gemini/services/Gemini_service.dart';
import 'package:easy_localization/easy_localization.dart';
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
  bool isLoading = false;
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
      //_isCorrect = value == _questions[_currentStep].correctAnswer;
      //_optionSelected = true;
      _answerSubmitted = true;

      /*if (value == _questions[_currentStep].correctAnswer) {
        _questions[_currentStep].isCompleted = true;
      }
      if (_isCorrect) {
        _feedbackMessage = '¡Correcto!';
      } else {
        _feedbackMessage = 'Incorrecto. La respuesta correcta es: ${_questions[_currentStep].correctAnswer}';
      }*/
   });
  }

  void _evaluateQuestion() async {
    if (_questions[_currentStep].type=='open') {
      setState(() {
        isLoading = true;
      });

      bool response = await gem.evaluateAnswer(_questions[_currentStep].question, _answerText!, _questions[_currentStep].correctAnswer!);
      _isCorrect = response;
      _showResult = false;

      setState(() {
        isLoading = false;
      });

    } else {
      _isCorrect = _selectedOption == _questions[_currentStep].correctAnswer; // Local evaluation
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,

      builder: (BuildContext context) {
        return Container(
          height: 200,
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          child: Expanded(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                  _isCorrect?"Correct answer".tr():"Incorrect answer".tr(),
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
              ),
              Text(
                  '${"Answer is:".tr()}${" "}${_questions[_currentStep].correctAnswer}',
                  textAlign: TextAlign.left,
              ),
              SizedBox(height: 8, width: double.infinity),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _nextQuestion();
                },
                child: Text("Next").tr(),
              ),
            ],
          ),
            )
        );
      },
    );

  }

  void _nextQuestion() async {
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

  void _answerSubmittedCallback(String answer) {
    setState(() {
      _answerText = answer;
      _answerSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    _questions = args['questions'];
    topic = args['topic'] as Topic;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:

      Stack(
          children: [
        Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
          child:
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  child: Stepper(
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
                        content:
                       Column(
                          children: [
                            Text(
                                question.question,
                                style:TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 32.0),
                            _buildQuestion(question),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildButton(),
                ),

              ],
            ),
       ),
            if (isLoading)
              const Opacity(
                opacity: 0.8,
                child: ModalBarrier(dismissible: false, color: Colors.black),
              ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

    ]
      )
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
                    onChanged: _answerSelected,
                  ))
              .toList(),
        );
      case "open":
        return TextField(
          onChanged: (value) => _answerSubmittedCallback(value),
          decoration: InputDecoration(hintText: "Write your answer".tr()),
        );
      default:
        return Text("Type of question not suported").tr();
    }
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _evaluateQuestion();
        },
        child: Text("Check", style: TextStyle(fontSize: 16 ),).tr(),
      ),
    );
  }

}


/*
* _answerSubmitted
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
                        _isCorrect ? '¡Respuesta correcta!' : '¡Respuesta incorrecta!',
                        style: TextStyle(fontSize: 18),
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
*
* */




