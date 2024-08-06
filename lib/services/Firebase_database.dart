import 'dart:convert';
import 'dart:io';

import 'package:app_gemini/global/common/toast.dart';
import 'package:app_gemini/interfaces/DocumentInterface.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/services/Gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


String lastSavedTopicId = ''; 

class FirebaseDatabase {

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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


  void SaveTranscript (String markdownContent, String filePath) async{
    String fileName = "transcript.txt";
    String newContent = markdownContent;
    final storageRef = _storage.ref().child(filePath).child(fileName);

    try {

      final existingData = await storageRef.getData();
      if (existingData != null) {
        // Append new content to the existing content
        final existingContent = utf8.decode(existingData);
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

  void saveTopic(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId= prefs.getString('user_id');

    if (name.isNotEmpty) {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentReference topicRef = await userRef.collection('topics').add({'name': name});
      lastSavedTopicId = topicRef.id;
    }
  }

  void DeleteTopic(String topicId) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    await _firestore.collection('users').doc(userId).collection('topics').doc(topicId).delete();
    showToast(message: "${"Topic succesfully removed: ".tr()}");
  } catch (error) {
       showToast(message: "${"Error deleting topic: ".tr()}");
  }
}

void EditTopic(String topicId, String newName, GlobalKey<FormState> _formKey,BuildContext context) async {
      if (_formKey.currentState!.validate()) {
        try {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final userId = prefs.getString('user_id');

          await _firestore.collection('users').doc(userId).collection('topics').doc(topicId).update({
            'name': newName,
          });
          showToast(message: "${"Topic updated successfully".tr()}");
          Navigator.of(context).pop();
        } catch (error) {
          showToast(message: "${"Error updating topic: ".tr()}");
        }
      }
}

  Stream<List<Topic>> getTopicsUser() async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    try {
      CollectionReference topicsCollection = _firestore.collection('users').doc(userId).collection('topics');
      yield* topicsCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Topic(name: doc['name'], uid: doc.id);
        }).toList();
      });
    } catch (e) {
      print("${"Error getting topics: ".tr()} $e");
      yield [];
    }
  }

  Future<void> pickAndUploadFiles2(String topicId, Function(double) onProgress) async {
    final GeminiService gem = GeminiService();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: true,
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    String fileTxtPath = 'users/$userId/topics/$topicId/';
    String markdownContent = '';

    if (result != null && userId != null) {
      int totalFiles = result.files.length;
      int processedFiles = 0;

      for (var file in result.files) {
        if (file.path != null) {
          File selectedFile = File(file.path!);

          String fileName = file.name;
          String filePath = 'users/$userId/topics/$topicId/$fileName';

          try {
            // Subir archivo
            await _storage.ref(filePath).putFile(selectedFile);

            String downloadURL = await _storage.ref(filePath).getDownloadURL();

            markdownContent = '$markdownContent\n${await gem.transcriptDocument(selectedFile, downloadURL)}';

            await _firestore.collection('users').doc(userId).collection('topics').doc(topicId).collection('documents').add({
              'fileName': fileName,
              'url': downloadURL,
              'uploadedAt': Timestamp.now(),
            });

            processedFiles++;
            onProgress(processedFiles / totalFiles);

          } catch (e) {
            showToast(message: "${"Error in save document".tr()} $e");
            print(e);
          }
        }
      }

      SaveTranscript(markdownContent, fileTxtPath);
    } else {
      showToast(message: "No files selected".tr());
    }
  }


  Future<void> pickAndUploadFiles(String topicId) async {
    final GeminiService gem = GeminiService();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: true,
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    String fileTxtPath = 'users/$userId/topics/$topicId/';
    String markdownContent = '';

    if (result != null && userId != null) {
      for (var file in result.files) {
        if (file.path != null) {
          File selectedFile = File(file.path!);

          String fileName = file.name;
          String filePath = 'users/$userId/topics/$topicId/$fileName';


          try {
            await _storage.ref(filePath).putFile(selectedFile);

            String downloadURL = await _storage.ref(filePath).getDownloadURL();

            markdownContent = '$markdownContent\n${await gem.transcriptDocument(selectedFile, downloadURL)}';

            await _firestore.collection('users').doc(userId).collection('topics').doc(topicId).collection('documents').add({
              'fileName': fileName,
              'url': downloadURL,
              'uploadedAt': Timestamp.now(),
            });

          } catch (e) {
            showToast(message: "${"Error in save document: ".tr()} $e");
            print(e);
          }
        }
      }

      SaveTranscript(markdownContent, fileTxtPath);

    } else {
      showToast(message: "No files selected".tr());
    }
  }

  Stream<List<Document>> loadDocuments(String topicId) async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('user_id');

    try {
      CollectionReference documentsCollection = _firestore.collection('users').doc(uid).collection('topics').doc(topicId).collection('documents');
      yield* documentsCollection.orderBy('uploadedAt', descending: true).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Document.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print("${"Error getting documents: ".tr()} $e".tr());
      yield [];
    }
  }

  Future<String> getDocumentMarkdown(String topicId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    try {
      String documentPath = 'users/$userId/topics/$topicId/transcript.txt';
      final storageRef = FirebaseStorage.instance.ref().child(documentPath);
      final url = await storageRef.getDownloadURL();
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return decodedBody;
      } else {
        throw Exception('Failed to load document from Firebase Storage');
      }
    } catch (e) {
      return "You don't have files in this theme, add some".tr();
    }
  }

  Future<void> deleteDocument(String topicId, String documentId, String fileName) async {
    //todo: agregar codigos en los transcritos y eliminar o editar
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    try {
      DocumentReference documentRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('topics').doc(topicId).collection('documents').doc(documentId);
      Reference fileRef = _storage.ref().child('users/$userId/topics/$topicId/$fileName');
      await documentRef.delete();
      await fileRef.delete();
      print("Document succesfully removed".tr());
    } catch (e) {
      print("${"Error removing: ".tr()} $e".tr());
    }
  }

  Future<List<String>> getTopicIds(String userId) async {
    List<String> topicIds = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('topics')
        .get();
    querySnapshot.docs.forEach((doc) {
      topicIds.add(doc.id);
    });
    return topicIds;
  }

  Future<String> getTranscriptContent(String userId, String topicId) async {
    String filePath = 'users/$userId/topics/$topicId/transcript.txt';
    try {
      Reference ref = FirebaseStorage.instance.ref().child(filePath);

      String transcriptContent = await ref.getDownloadURL().then((fileUrl) async {
        final response = await http.get(Uri.parse(fileUrl));
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception('Failed to load transcript');
        }
      });

      return transcriptContent;
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<String> combineTranscripts(String userId) async {
    List<String> topicIds = await getTopicIds(userId);
    String combinedContent = '';

    for (String topicId in topicIds) {
      String transcriptContent = await getTranscriptContent(userId, topicId);
      if (transcriptContent != null) {
        combinedContent += transcriptContent + '\n';
      }
    }

    return combinedContent;
  }

}