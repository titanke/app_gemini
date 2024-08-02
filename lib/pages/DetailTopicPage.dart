import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/pages/quiz/IntrodutionPage.dart';
import 'package:app_gemini/pages/quiz/QuizPage.dart';
import 'package:app_gemini/pages/StorageDetailPage.dart';
import 'package:app_gemini/pages/TopicOverview.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:flutter/material.dart';

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
      _isLoading = documentMarkdown == 'No tienes archivos en este tema, agrega algunos';
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


/*
* class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Topic data = ModalRoute.of(context)?.settings.arguments as Topic;
    final List<Widget> _children = [
      TopicOverviewScreen(dato: data),
      FileStorageScreen(),
      QuizPage(dato: data.name)
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Temas: ${data.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.storage),
            onPressed: () {
              setState(() {
                currentIndex = 1;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              setState(() {
                currentIndex = 2;
              });
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _children,
      ),
    );
  }
}
*
* */