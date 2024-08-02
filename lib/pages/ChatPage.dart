import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({super.key});

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  String text = '';
  TextEditingController prompt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    getRes(String prompt) async {
      var apiKey = dotenv.env['API_KEY'];
      final model = GenerativeModel(model: 'gemini-1.5-pro-latest', apiKey: apiKey!);
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      setState(() {
        text = response.text!;
      });
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gemini Chatpage"),
      ),
      body: Column(
        children: [
          Expanded(
            child: MarkdownBody(data: text),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: prompt,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    getRes(prompt.text);
                  },
                  icon: const Icon(Icons.arrow_circle_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
