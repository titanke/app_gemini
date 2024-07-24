import 'package:flutter/material.dart';

class Topicspage extends StatefulWidget {
  const Topicspage({Key? key}) : super(key: key);

  @override
  _TopicspageState createState() => _TopicspageState();
}

class _TopicspageState extends State<Topicspage> {
  final List<Topic> _topics = [
    Topic('Topic 1', 'https://www.example.com/topic1'),
    Topic('Topic 2', 'https://www.example.com/topic2'),
    Topic('Topic 3', 'https://www.example.com/topic3'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topic List'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _topics.length,
          itemBuilder: (context, index) {
            final topic = _topics[index];
            return InkWell(
              onTap: () {
                // Navigate to the topic's screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopicScreen(topic: topic),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  topic.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Topic {
  final String title;
  final String url;

  Topic(this.title, this.url);
}

class TopicScreen extends StatelessWidget {
  final Topic topic;

  const TopicScreen({Key? key, required this.topic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
      ),
      body: Center(
        child: Text(topic.url),
      ),
    );
  }
}
