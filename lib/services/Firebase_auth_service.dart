import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseAuthService {
  FirebaseAuth _auth =  FirebaseAuth.instance;

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;


    }catch(e){
      print("Error in authentication");
    }

  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;


    }catch(e){
      print("Error in authentication");
    }

  }
}