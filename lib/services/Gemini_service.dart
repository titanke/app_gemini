import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

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

    final prompt = """
    Transcribe the following file into Markdown format unless
    if the file is an image and it hasn't text, generate a title and below it the URL: $url in this format:
    title
    ![title]($url)
    if the file isn't an image only transcribe it.
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
}