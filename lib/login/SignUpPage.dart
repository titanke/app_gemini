import 'package:app_gemini/global/common/toast.dart';
import 'package:app_gemini/login/LoginPage.dart';
import 'package:app_gemini/services/Firebase_auth_service.dart';
import 'package:app_gemini/widgets/FormContainerWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _interestController = TextEditingController();

  bool isSigningUp = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      /*appBar: AppBar(
        automaticallyImplyLeading: false,
        //title: Text("SignUp"),
      ),*/
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
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
              /*FormContainerWidget(
                controller: _usernameController,
                hintText: "Username",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),*/
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
                height: 10,
              ),
              FormContainerWidget(
                controller: _ageController,
                hintText: "Age".tr(),
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _interestController,
                hintText: "Interest".tr(),
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _countryController,
                hintText: "Country".tr(),
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap:  (){
                  _signUp();

                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: isSigningUp ? CircularProgressIndicator(color: Colors.white,):Text(
                        "Sign Up".tr(),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {

    setState(() {
      isSigningUp = true;
    });

    //String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String age = _ageController.text;
    String country = _countryController.text;
    String interest = _interestController.text;

    try {
      User? user = await _auth.signUpWithEmail(
          email, password, age, interest, country);

      setState(() {
        isSigningUp = false;
      });
      if (user != null) {
        showToast(message: "User is successfully created".tr());
        Navigator.pushNamed(context, "/ftpage");
      } else {
        showToast(message: "Some error happend in register".tr());
      }
    }catch(e){
      showToast(message: e.toString());
      setState(() {
        isSigningUp = false;
      });
    }


  }
}