import 'package:app_gemini/pages/quiz/QuizPage.dart';
import 'package:app_gemini/pages/StorageDetailPage.dart';
import 'package:app_gemini/pages/TopicOverview.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';

class DetailScreen extends StatefulWidget {
  final Topic topic;

  const DetailScreen({required this.topic});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
    bool _isLoading = true; 
    FirebaseDatabase db = FirebaseDatabase();

    @override
    void initState() {
      super.initState();
      _fetchData();
    }
    Future<void> _fetchData() async {
      final String documentMarkdown = await db.getDocumentMarkdown(widget.topic.uid);
      setState(() {
      _isLoading = documentMarkdown == "You don't have files in this theme, add some".tr();
      });
    }

      @override
  Widget build(BuildContext context) {
 return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/home', arguments: 1);
            }
      ),
        actions: [
          IconButton(
            icon: Icon(Icons.storage),
            onPressed: () {
            Navigator.pushNamed(context, '/storage', arguments: widget.topic.uid);
            },
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
           onPressed: _isLoading ? null : () {
              Navigator.pushNamed(context, '/quiz', arguments: widget.topic);
            },
          ),
          
        ],
      ),
      body: TopicOverviewScreen(topic: widget.topic),
    );
}
}
