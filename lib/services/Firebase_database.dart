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

class FirebaseDatabase {

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService gem = GeminiService();

  void saveTopic(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId= prefs.getString('user_id');

    if (name.isNotEmpty) {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      await userRef.collection('topics').add({'name': name});

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

}