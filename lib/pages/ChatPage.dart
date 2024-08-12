import 'package:app_gemini/global/common/toast.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:app_gemini/services/Gemini_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final FirebaseDatabase db = FirebaseDatabase();
  List<Message> messages = [
    Message("chat introduction".tr(),
        false)
  ];
  TextEditingController prompt = TextEditingController();
  final GeminiService gem = GeminiService();
  String contextTopic = "";
  bool isLoading = false;
  bool isLoadingContext = false;

  List<Topic> listTopics = [];
  Topic selectedTopic = Topic(name: '', uid: '');

  late AnimationController _animationController;

  final ScrollController _scrollController = ScrollController();

  void didChangeDependencies() {
    super.didChangeDependencies();
    context.locale;
  }

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
    final temp = await db.getTopicsUser2();
    setState(() {
      listTopics = temp;
    });
    /*try {
      final retrievalQAChain = await gem.initRag();
      print('initializing RAG');
      setState(() {
        rag = retrievalQAChain;
      });
    } catch (e) {
      print('Error initializing RAG: $e');
    }*/
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

  Future<void> getRes(String asnwer) async {
    setState(() {
      isLoading = true;
    });

    try {
      String response = await gem.chatResponse(asnwer, contextTopic);
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
          leading: SizedBox(height: 12),
          title: Center(
            child: Text(
              "Study Companion",
              style: TextStyle(
                // color: Colors.white,
                fontSize: 20,
              ),
            ).tr(),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  if (messages.length > 1)
                    setState(() {
                      messages = [
                        Message("chat introduction".tr(),false)
                      ];
                    });
                },
                icon: Icon(Icons.delete_forever))
          ],
          backgroundColor: const Color(
              0xFFFFA500), // Set the background color for the AppBar if needed
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                            padding: EdgeInsets.all(1.0),
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
                                  horizontal: 0, vertical: 8.0),
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
              Column(
                children: [
                  if (messages.length == 1)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(listTopics.length, (index) {
                          final topic = listTopics[index];

                          return Padding(
                              padding: EdgeInsets.only(
                                left: index == 0 ? 16.0 : 0,
                                right: 8.0,
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  final userId = prefs.getString('user_id');
                                  contextTopic = await db.getTranscriptContent(
                                      userId!, topic.uid);
                                  if (contextTopic == "")
                                    showToast(
                                        message: "El tema no tiene contenido");
                                  else {
                                    setState(() {
                                      messages.add(Message(topic.name, true));
                                      messages.add(Message(
                                          "${"chat_what".tr()} ${topic.name}?",
                                          false));
                                      selectedTopic = topic;
                                    });
                                  }
                                },
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: 120,
                                  ),
                                  child: Chip(
                                    label: Text(
                                      topic.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      side: BorderSide(
                                          color: Color(0xFFFFB84D), width: 2.5),
                                    ),
                                  ),
                                ),
                              ));
                        }),
                      ),
                    ),
                  SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.black, width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: prompt,
                            decoration: InputDecoration(
                              hintText: "Writte your answer...".tr(),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (contextTopic == "") {
                              showToast(message: "Debes seleccionar un tema");
                              return;
                            }

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
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
