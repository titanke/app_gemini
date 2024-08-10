import 'package:app_gemini/services/Gemini_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:langchain/langchain.dart';

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

class _ChatpageState extends State<Chatpage>
    with SingleTickerProviderStateMixin {
  List<Message> messages = [];
  TextEditingController prompt = TextEditingController();
  final GeminiService gem = GeminiService();
  RetrievalQAChain? rag;
  bool isLoading = false;

  late AnimationController _animationController;

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    if (mounted) {
      super.initState();
      _initializeRag();
      _animationController = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      )..repeat(reverse: true);
    }
  }

  Future<void> _initializeRag() async {
    try {
      final retrievalQAChain = await gem.initRag();
      print('initializing RAG');
      setState(() {
        rag = retrievalQAChain;
      });
    } catch (e) {
      print('Error initializing RAG: $e');
    }
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

  Future<void> getRes(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      String response = await gem.ragResponse(rag!, query);
      setState(() {
        messages.add(Message(response, false));
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
        // ignore: prefer_const_constructors
        title: Center(
          // ignore: prefer_const_constructors
          child: Text(
            'General Chat',
            // ignore: prefer_const_constructors
            style: TextStyle(
              // color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: const Color(
            0xFFFFA500), // Set the background color for the AppBar if needed
      ),
      body: rag == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
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
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Writting...".tr()),
                            ),
                          ),
                        );
                      }
                      final message = messages[index];
                      return Align(
                        alignment: message.isUserMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: message.isUserMessage
                                      ? const Color(0xFFF2AA00)
                                      : const Color(0xFFBF8600),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: MarkdownBody(
                                  data: message.text,
                                ),
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
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black, // Color del borde
                                width: 24.0, // Grosor del borde
                              ),
                              borderRadius: BorderRadius.circular(
                                  12.0), // Radio de las esquinas (opcional)
                            ),
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
