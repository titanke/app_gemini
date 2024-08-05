import 'package:easy_localization/easy_localization.dart';
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


  class Message {
    final String text;
    final bool isUserMessage;

    Message(this.text, this.isUserMessage);
  }

class _ChatpageState extends State<Chatpage> with SingleTickerProviderStateMixin{
  List<Message> messages = [];
  TextEditingController prompt = TextEditingController();
  bool isLoading = false;
  final String initialPrompt = "Eres un chatbot que ayuda al usuario a repasar.";
  late AnimationController _animationController;

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> getRes(String prompt) async {
    setState(() {
      isLoading = true;
    });

    try {
      var apiKey = dotenv.env['API_KEY'];
      final model = GenerativeModel(model: 'gemini-1.5-pro-latest', apiKey: apiKey!);
      final content = [Content.text("$initialPrompt $prompt")];
      final response = await model.generateContent(content);

      setState(() {
        messages.add(Message(response.text!, false));
        isLoading = false;
      });
      _scrollToBottom();
    } catch (error) {
      // Handle errors here
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Companion").tr(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, 
              reverse: false,
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return FadeTransition(
                    opacity: _animationController,
                    child:  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Writting...").tr(),
                      ),
                    ),
                  );
                }
                final message = messages[index];
                return Align(
                  alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
             
                      Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: message.isUserMessage ? const Color.fromARGB(255, 25, 43, 58) : const Color.fromARGB(255, 223, 88, 88),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(message.text),
                            ),
                          ),
                   
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: prompt,
                    decoration: InputDecoration(
                      hintText: "Writte your answer...".tr(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final text = prompt.text;
                    if (text.isNotEmpty) {
                      setState(() {
                        messages.add(Message(text, true));
                      });
                      prompt.clear();
                      getRes(text);
                      _scrollToBottom();
                    }
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
