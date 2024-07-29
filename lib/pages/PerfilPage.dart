import 'package:app_gemini/global/common/toast.dart';
import 'package:app_gemini/login/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilPage extends StatelessWidget {

  Future<void> _signOut(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await FirebaseAuth.instance.signOut();
      await prefs.setString('user_id', "");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print(e);
      showToast(message: "some error signing out occured $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
          Stack(
          children: [
            ElevatedButton(onPressed: () => _signOut(context), child: Text('Sign Out'))
          ],
          )
      ),
    );
  }
}