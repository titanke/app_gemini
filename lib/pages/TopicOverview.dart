import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:flutter/cupertino.dart';

class TopicOverviewScreen extends StatelessWidget {
  final Topic dato;

  const TopicOverviewScreen({required this.dato});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(dato.name),
    );
  }
}
