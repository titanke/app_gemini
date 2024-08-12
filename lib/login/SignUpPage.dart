import 'package:app_gemini/global/common/toast.dart';
import 'package:app_gemini/login/LoginPage.dart';
import 'package:app_gemini/services/Firebase_auth_service.dart';
import 'package:app_gemini/widgets/FormContainerWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/widgets/Tfield.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isSigningUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              // Envuelve los campos en un Form
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sign Up".tr(),
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  FormContainerWidget(
                    controller: _emailController,
                    hintText: "Email".tr(),
                    isPasswordField: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email".tr();
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return "Please enter a valid email".tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FormContainerWidget(
                    controller: _passwordController,
                    hintText: "Password".tr(),
                    isPasswordField: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password".tr();
                      } else if (value.length < 8) {
                        return "Password must be at least 8 characters".tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FormContainerWidget(
                    controller: _ageController,
                    hintText: "Age".tr(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your age".tr();
                      } else if (int.tryParse(value) == null) {
                        return "Please enter a valid number".tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        _signUp();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: isSigningUp
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "Sign Up".tr(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?").tr(),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                                (route) => false);
                          },
                          child: Text(
                            "Login".tr(),
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;
    String age = _ageController.text;

    try {
      User? user = await _auth.signUpWithEmail(email, password, age, "", "");

      setState(() {
        isSigningUp = false;
      });
      if (user != null) {
        showToast(message: "User is successfully created".tr());
        Navigator.pushReplacementNamed(context, "/IntroPage");
      } else {
        showToast(message: "Some error happend in register".tr());
      }
    } catch (e) {
      showToast(message: e.toString());
      setState(() {
        isSigningUp = false;
      });
    }
  }
}
