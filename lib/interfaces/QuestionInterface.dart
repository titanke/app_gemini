class Question {
  final String question;
  final List<String>? options;
  final String? correctAnswer;
  final String? type;
  bool isCompleted = false;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.type ,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      correctAnswer: json['answer'] as String?,
      type: json['type'] as String?,
    );
  }
}