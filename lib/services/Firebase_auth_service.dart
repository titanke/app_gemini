import 'dart:ffi';

import 'package:app_gemini/global/common/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  FirebaseAuth _auth =  FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<User?> signUpWithEmail(String email, String password, String age, String interest, String country) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {

      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      String uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'age': age,
        'country': country,
        'interest': interest,
      });

      await prefs.setString('user_id', uid);
      return credential.user;

    }catch(e){
      throw("Error in authentication $e".tr());
    }

  }

  Future<User?> signInWithEmail(String email, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = credential.user!.uid;
      await prefs.setString('user_id', uid);
      return credential.user;

      return credential.user;

    }catch(e){
      print("Error in authentication".tr());
    }

  }

  Future<Map<String, Object?>?> signInWithGoogle() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool newUser = false;
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        UserCredential credentialUser = await _auth.signInWithCredential(credential);
        User? user = credentialUser.user;
        String uid = credentialUser.user!.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'email': user?.email,
            'age': "",
            'country': "",
            'interest': "",
            'newUser': true,
          });
          newUser = true;
        }

        await prefs.setString('user_id', uid);
        return { "user":credentialUser.user,"newUser":newUser};
      }
    } catch (e) {
      showToast(message: "Some error occurred: $e".tr());
    }

    return null;
  }
}