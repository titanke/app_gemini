import 'dart:convert';
import 'dart:io';

import 'package:app_gemini/global/common/toast.dart';
import 'package:app_gemini/interfaces/DocumentInterface.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/services/Gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


String lastSavedTopicId = ''; 

class FirebaseDatabase {

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService gem = GeminiService();

  void saveTopic(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId= prefs.getString('user_id');

    if (name.isNotEmpty) {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentReference topicRef = await userRef.collection('topics').add({'name': name});
      lastSavedTopicId = topicRef.id;
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
      print('Error getting themes: $e');
      yield [];
    }
  }

  Future<void> pickAndUploadFiles2(String topicId, Function(double) onProgress) async {
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
            showToast(message: 'Error in save document $e');
            print(e);
          }
        }
      }

      gem.SaveTranscript(markdownContent, fileTxtPath);
    } else {
      showToast(message: 'No files selected');
    }
  }


  Future<void> pickAndUploadFiles(String topicId) async {
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
            showToast(message: 'Error in save document $e');
            print(e);
          }
        }
      }

      gem.SaveTranscript(markdownContent, fileTxtPath);

    } else {
      showToast(message: 'No files selected');
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
      print('Error getting documents: $e');
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
      return 'No tienes archivos en este tema, agrega algunos';
    }
  }

  Future<void> deleteDocument(String topicId, String documentId, String fileName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    try {
      DocumentReference documentRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('topics').doc(topicId).collection('documents').doc(documentId);
      Reference fileRef = _storage.ref().child('users/$userId/topics/$topicId/$fileName');
      await documentRef.delete();
      await fileRef.delete();
      print('Documento eliminado exitosamente');
    } catch (e) {
      print('Error al eliminar el documento: $e');
    }
  }

}