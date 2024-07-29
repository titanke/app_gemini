import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/pages/Quiz/QuizPage.dart';
import 'package:app_gemini/pages/StorageDetailPage.dart';
import 'package:app_gemini/pages/TopicOverview.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Topic dato = ModalRoute.of(context)?.settings.arguments as Topic;

    return Scaffold(
      appBar: AppBar(
        title: Text(dato.name),
        actions: [
          IconButton(
            icon: Icon(Icons.storage),
            onPressed: () {
              Navigator.pushNamed(context, '/storage', arguments: dato.uid);
            },
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.pushNamed(context, '/quiz', arguments: dato);
            },
          ),

        ],
      ),
      body: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case 'content':
              builder = (BuildContext context) => TopicOverviewScreen(dato: dato);
              break;
            case 'storage':
              final String uid = settings.arguments as String;
              builder = (BuildContext context) => FileStorageScreen();
              break;
            case 'detail/quiz':
              final Topic dato = settings.arguments as Topic;
              builder = (BuildContext context) => QuizPage(dato: dato.name);
              break;
            default:
              throw Exception('Ruta no válida: ${settings.name}');
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
        initialRoute: 'content',
      ),
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