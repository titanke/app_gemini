import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const String chatApiUrl = 'https://your-api-endpoint.com/chat';

class Chatpage extends StatefulWidget {
  @override
  _ChatpageState createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  bool _isSendingMessage = false;
  final _messageController = TextEditingController();
  List<String> _messages = []; 
  Future<void> _sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(chatApiUrl),
        body: {'message': message},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final receivedMessage = responseData['message']; 
        setState(() {
          _messages.add(message);
          _messages.add(receivedMessage);
        });
        _messageController.clear(); 
      } else {
        print('Error sending message: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message. Please try again.'),
          ),
        );
      }
    } catch (error) {
      print('Error sending message: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message == _messageController.text
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: message == _messageController.text
                          ? Colors.blue[200]
                          : Colors.grey[200],
                    ),
                    child: Text(message),
                  ),
                );
              },
            ),
          ),
          Form(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
