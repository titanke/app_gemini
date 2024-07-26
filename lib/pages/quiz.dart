import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class QuizPage extends StatefulWidget {
  final String dato;
   QuizPage({super.key, required this.dato});

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

  final String _apiUrl = 'YOUR_API_URL'; 
  final http.Client _httpClient = http.Client();

  final List<Question> _questions = [
    Question(
      question: '¿Cuál es la función principal del corazón?',
      options: ['Respirar', 'Digerir', 'Bombear sangre', 'Producir hormonas'],
      correctAnswer: 'Bombear sangre',
      type: 'multipleChoice',
    ),
    Question(
      question: '¿Cuál es la enfermedad más común transmitida por mosquitos?',
      options: ['Dengue', 'Gripe', 'COVID-19', 'Varicela'],
      correctAnswer: 'Dengue',
      type: 'multipleChoice',
    ),  
     Question(
      question: '¿Cuál es la enfermedad más común transmitida por mosquitos?',
      type: 'text',
    ), 
    ];

  String? _feedbackMessage;

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
  /*
  void _nextQuestion() {
    if (_optionSelected && _isCorrect) {
      setState(() {
    if (_currentStep < _questions.length - 1) {
            _currentStep++;
          } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsPage(correctAnswers, _questions.length),
            ),
          );
          }       _selectedOption = null;
            _optionSelected = false;
            _feedbackMessage = null;
                  correctAnswers++;
          });
        }
      }*/

        void _nextQuestion() async {
    if (_answerSubmitted) {
      if (_questions[_currentStep].isAnswerEvaluatedByAPI) {
        final response = await _evaluateAnswer(_answerText!);
        setState(() {
          _isCorrect = response['isCorrect']; // Parse the response to determine correctness
        });
      } else {
        _isCorrect =
            _answerText == _questions[_currentStep].correctAnswer; // Local evaluation
      }

      setState(() {
        _questions[_currentStep].isCompleted = true;
        if (_currentStep < _questions.length - 1) {
          _currentStep++;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsPage(correctAnswers, _questions.length),
            ),
          );
        }
        _answerText = null;
        _answerSubmitted = false;
      });
      correctAnswers += _isCorrect ? 1 : 0;
    }
  }
      //api test form
        void _fetchQuestion() async {
    final response = await _httpClient.get(Uri.parse(_apiUrl));

    if (response.statusCode == 200) {
      final questionData = jsonDecode(response.body); // Parse the JSON response
      final question = Question(
          question: questionData['question'],
          options: questionData['options'].cast<String>(),
          correctAnswer: questionData['correctAnswer']);
      setState(() {
        _questions.add(question);
      });
    } else {
      // Handle API error
      print('Error fetching question: ${response.statusCode}');
      // Consider showing an error message to the user
    }
  }

  void _answerSubmittedCallback(String answer) {
    setState(() {
      _answerText = answer;
      _answerSubmitted = true;
    });
  }
    Future<Map<String, dynamic>> _evaluateAnswer(String answer) async {
    // Make an HTTP POST request to your API endpoint for evaluation
    final uri = Uri.parse(_apiUrl + '/evaluate'); // Adjust endpoint URL if needed
    final response = await _httpClient.post(uri, body: {'answer': answer});

    if (response.statusCode == 200) {
      final evaluationData = jsonDecode(response.body);
      return evaluationData;
    } else {
      // Handle API evaluation error
      print('Error evaluating answer: ${response.statusCode}');
      throw Exception('Failed to evaluate answer'); // Consider showing an error message
    }
  }


      //

  @override
  /*
  Widget build(BuildContext context) {
       return Scaffold(
      appBar: AppBar(title: Text('Temas: ${widget.dato}')),
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
        },        steps: _questions.map((question) {
          return Step(
            title: Text(''),
              state: question.isCompleted ? StepState.complete : StepState.disabled,

            content: Column(
              children: [
                Text(question.question),
                ...question.options.map((option) {
                  return RadioListTile(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedOption,
                    onChanged: _answerSelected,
                  );
                }),
                if (_feedbackMessage != null) Text(_feedbackMessage!),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text('Confirmar'),
                ),
              ],
              
            ),
            
          );
        }).toList(),
        
      ),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;
  bool isCompleted = false;

  Question({required this.question, required this.options, required this.correctAnswer});
}*/

 

Widget build(BuildContext context) {
       return Scaffold(
      appBar: AppBar(title: Text('Temas: ${widget.dato}')),
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
                if (_feedbackMessage != null) Text(_feedbackMessage!),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text('Siguiente'),
                ),
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
                  onChanged: _answerSelected,
                ))
            .toList(),
      );
        case "text":
      return TextField(
        onChanged: (value) => _answerSubmittedCallback(value),
        decoration: InputDecoration(hintText: 'Ingrese su respuesta'),
      );
    default:
      return Text('Tipo de pregunta no soportado');
  }
}





}

class Question {
  final String question;
  final List<String>? options;
  final bool isAnswerEvaluatedByAPI;
  final String? correctAnswer;
  final String? type; 
  bool isCompleted = false;

  Question({
    required this.question,
    this.options,
    this.isAnswerEvaluatedByAPI = false,
    this.correctAnswer,
    this.type ,
  });
}


class ResultsPage extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;

  const ResultsPage(this.correctAnswers, this.totalQuestions, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resultados')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¡Felicidades! Has terminado el quiz.'),
            Text('Obtuviste $correctAnswers respuestas correctas de $totalQuestions.'),
             TextButton(
              onPressed: () {
          
                Navigator.pop(context); 
              },
              child: Text('Continuar'),
            ),
            TextButton(
              onPressed:() {
                Navigator.pop(context); 
              },
              child: Text('Salir'),
            ),
          ],
        ),
      ),
    );
  }
}