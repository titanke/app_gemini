import 'dart:io';

import 'package:app_gemini/global/common/toast.dart';
import 'package:app_gemini/interfaces/DocumentInterface.dart';
import 'package:app_gemini/interfaces/topicInterface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseDatabase {

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void saveTopic(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId= prefs.getString('user_id');

    if (name.isNotEmpty) {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      await userRef.collection('topics').add({'name': name});

    }
  }

  Future<List<Topic>> getTopicsUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId= prefs.getString('user_id');
    try {
      CollectionReference themesCollection = _firestore.collection('users').doc(userId).collection('topics');
      QuerySnapshot querySnapshot = await themesCollection.get();

      List<Topic> topics = querySnapshot.docs.map((doc) {
        return Topic(name: doc['name'], uid: doc.id );
      }).toList();

      return topics;
    } catch (e) {
      print('Error getting themes: $e');
      return [];
    }
  }

  Future<void> pickAndUploadFile(String topicId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId= prefs.getString('user_id');

    if (result != null) {
      File file = File(result.files.single.path!);

      String? uid = userId;
      String fileName = result.files.single.name;
      String filePath = 'users/$uid/topics/$topicId/$fileName';

      try {
        await _storage.ref(filePath).putFile(file);

        String downloadURL = await _storage.ref(filePath).getDownloadURL();

        await _firestore.collection('users').doc(uid).collection('topics').doc(topicId).collection('documents').add({
          'fileName': fileName,
          'url': downloadURL,
          'uploadedAt': Timestamp.now(),
        });

        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File uploaded successfully')));
      } catch (e) {
        showToast(message: 'Error in save document $e');
        print(e);
        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload file')));
      }
    }
  }

  Future<List<Document>> loadDocuments(String topicId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('user_id');
    QuerySnapshot querySnapshot = await _firestore.collection('users').doc(uid).collection('topics').doc(topicId).collection('documents').orderBy('uploadedAt', descending: true).get();

    return querySnapshot.docs.map((doc) => Document.fromFirestore(doc)).toList();
  }

}