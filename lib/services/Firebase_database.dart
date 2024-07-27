import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseDatabase {


  void saveTopic(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId= prefs.getString('user_id');

    if (name.isNotEmpty) {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.collection('topics').add({'name': name});

    }
  }

  Future<List<String>> getTopicsUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId= prefs.getString('user_id');
    try {
      CollectionReference themesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('topics');


      QuerySnapshot querySnapshot = await themesCollection.get();

      List<String> topics = querySnapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();

      return topics;
    } catch (e) {
      print('Error getting themes: $e');
      return [];
    }
  }

}