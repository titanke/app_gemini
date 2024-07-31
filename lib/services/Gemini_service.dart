import 'dart:convert';
import 'dart:io';

import 'package:app_gemini/interfaces/QuestionInterface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:langchain/langchain.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  final String? apiKey = dotenv.env['API_KEY'];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  void SaveTranscript (String markdownContent, String filePath) async{
    String fileName = "transcript.txt";
    String newContent = markdownContent;
    final storageRef = _storage.ref().child(filePath).child(fileName);

    try {

      final existingData = await storageRef.getData();
      if (existingData != null) {
        // Append new content to the existing content
        final existingContent = String.fromCharCodes(existingData);
        newContent = '$existingContent\n$markdownContent';
      }
    } catch (e) {
      print('Error checking existing file: $e');
    }

    final directory = await getTemporaryDirectory();
    final localFile = File('${directory.path}/$fileName');

    await localFile.writeAsString(newContent);

    try {
      await storageRef.putFile(localFile);
      print('File uploaded successfully');
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<String> transcriptDocument(File file, String url) async {
    if (apiKey == null) {
      print('No \$API_KEY environment variable');
      return '';
    }

    String mimeType = lookupMimeType(file.path)!;
    final fileBytes = await file.readAsBytes();

    String newurl = url.replaceAll('%2F', '*75');

    final prompt = """
    Transcribe the following file into Markdown format unless
    if the file is an image and it hasn't text, generate a title and below it the URL: $newurl in this format:
    title
    ![title]($newurl)
    if the file isn't an image only transcribe it into Markdown format without include the previous format of url.
    """;

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!);
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart(mimeType, fileBytes),
      ])
    ];
    final response = await model.generateContent(content);

    return  response.text!;

  }

  Future<File> getDocumentFromFirebase(String documentPath) async {
    final storageRef = _storage.ref().child(documentPath);
    final url = await storageRef.getDownloadURL();
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/document.txt');
      file.writeAsString(response.body);
      return file;
    } else {
      throw Exception('Failed to load document from Firebase Storage');
    }
  }

  Future<List<Question>> generateQuestions(String topicId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      String filePath = 'users/$userId/topics/$topicId/transcript.txt';
      File file = await getDocumentFromFirebase(filePath);

      String mimeType = lookupMimeType(file.path)!;
      final fileBytes = await file.readAsBytes();

      final prompt = """
        Dame 5 preguntas aleatorias basadas en este documento, las preguntas deben 
        ser del tipo de alternativa y respuesta abierta, además deben tener el siguiente formato JSON:
        [
          {
            question: ,
            options: ["a) opcion",],
            type: "multipleChoice" o "open",
            answer: 
          }
        ]
      """;



      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!);
      final content = [
        Content.multi([
          DataPart(mimeType, fileBytes),
          TextPart(prompt),
        ])
      ];
      final response = await model.generateContent(content);
      String responseText = response.text!;

      if (responseText.startsWith('```json')) {
        responseText = responseText.substring(7);
      }
      if (responseText.endsWith('```')) {
        responseText = responseText.substring(0, responseText.length - 3);
      }
      final List<dynamic> questionsJson = json.decode(responseText);

      return questionsJson.map((json) =>
          Question.fromJson(json as Map<String, dynamic>)).toList();
    }
    catch(e){
      print(e);
      return [];
    }

  }

  bool evaluateAnswer(String question, String answer) {

    return true;
  }
}