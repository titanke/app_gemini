import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/pages/quiz/IntrodutionPage.dart';
import 'package:app_gemini/pages/quiz/QuizPage.dart';
import 'package:app_gemini/pages/StorageDetailPage.dart';
import 'package:app_gemini/pages/TopicOverview.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Topic topic = ModalRoute.of(context)?.settings.arguments as Topic;

    return Scaffold(
      appBar: AppBar(
        title: Text(topic.name),
        actions: [
          IconButton(
            icon: Icon(Icons.storage),
            onPressed: () {
              Navigator.pushNamed(context, '/storage', arguments: topic.uid);
            },
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.pushNamed(context, '/quiz', arguments: topic);
            },
          ),

        ],
      ),
      body: TopicOverviewScreen(dato: topic),
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