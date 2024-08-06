import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:app_gemini/services/Gemini_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TopicOverviewScreen extends StatefulWidget {
  final Topic topic;
  final FirebaseDatabase db;

  const TopicOverviewScreen({required this.topic, required this.db});

  @override
  _TopicOverviewScreen createState() => _TopicOverviewScreen();
}

class _TopicOverviewScreen extends State<TopicOverviewScreen> {


  @override
  Widget build(BuildContext context) {
    FirebaseDatabase db = FirebaseDatabase();
    return Center(
      child: FutureBuilder<String>(
        future: db.getDocumentMarkdown(widget.topic.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: MarkdownBody(
                data: snapshot.data!,
                imageBuilder: (uri, title, alt) {
                  final updatedUri = uri.toString().replaceAll('*75', '%2F');
                  return Image.network(updatedUri);
                },
              ),
            );
          }
        },
      ),
    );
  }
}
