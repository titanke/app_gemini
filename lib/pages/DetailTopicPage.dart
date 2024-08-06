import 'package:app_gemini/pages/quiz/QuizPage.dart';
import 'package:app_gemini/pages/StorageDetailPage.dart';
import 'package:app_gemini/pages/TopicOverview.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';

class DetailScreen extends StatefulWidget {

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
    late Topic topic;
    final FirebaseDatabase db = FirebaseDatabase();


    @override
    Widget build(BuildContext context) {
        topic = ModalRoute.of(context)?.settings.arguments as Topic;


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
                FutureBuilder<bool>(
                  future: db.existContent(topic.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          Navigator.pushNamed(context, '/quiz', arguments: topic);
                        },
                      );
                    } else {
                      return IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: null,
                      );
                    }
                  },
                ),
              ],
            ),
            body: TopicOverviewScreen(topic: topic, db: db,),
          );
    }
}

