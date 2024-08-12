import 'package:app_gemini/global/common/toast.dart';
import 'package:app_gemini/login/SignUpPage.dart';
import 'package:app_gemini/services/Firebase_auth_service.dart';
import 'package:app_gemini/widgets/FormContainerWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  bool _isSigningGoogle = false;
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmail(email, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      showToast(message: "User is successfully signed in".tr());
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      showToast(message: "Some error occured".tr());
    }
  }

  _signInWithGoogle() async {
    setState(() {
      _isSigningGoogle = true;
    });
    try {
      Map<String, Object?>? data = await _auth.signInWithGoogle();
      if (data != null) {
        User? user = data['user'] as User?;
        bool newUser = data['newUser'] as bool;

        if (user != null) {
          if (newUser)
            Navigator.pushReplacementNamed(context, "/IntroPage");
          else
            Navigator.pushReplacementNamed(context, "/home");
        } else {
          showToast(message: "Some error occurred".tr());
        }
      } else {
        showToast(message: "Failed to sign in with Google".tr());
      }
    } catch (e){
      showToast(message: "Some error occurred: $e".tr());
    }

    setState(() {
      _isSigningGoogle = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
          ),
          body: PopScope(
            canPop: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/bundle-ardilla1.png', 
                      width:
                          150, 
                      height: 150,
                    ),
                    Text(
                      "WalNotes",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.orangeAccent),
                    ),
                    SizedBox(height: 20),
      
                    Text(
                      "Login",
                      style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    ).tr(),
      
      
                    SizedBox(
                      height: 30,
                    ),
                    FormContainerWidget(
                      controller: _emailController,
                      hintText: "Email".tr(),
                      isPasswordField: false,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FormContainerWidget(
                      controller: _passwordController,
                      hintText: "Password".tr(),
                      isPasswordField: true,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        _signIn();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: _isSigning
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).tr(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        _signInWithGoogle();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: _isSigningGoogle
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.google,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      "Sign in with Google",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ).tr(),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(" Don't have an account?").tr(),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                              (route) => false,
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ).tr(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
