import 'package:app_gemini/pages/FileUploaderScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:app_gemini/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:app_gemini/global/common/toast.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:app_gemini/services/Gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddTopic2 extends StatefulWidget {
  @override
  _AddTopicState createState() => _AddTopicState();
}

class _AddTopicState extends State<AddTopic2> {
  final _formKey = GlobalKey<FormState>();
  bool _isUploading = false;
  final TextEditingController _nameController = TextEditingController();
  final FirebaseDatabase _db = FirebaseDatabase();
  String userId = "";
  int _currentStep = 0;
  bool _step0Completed = false;
  bool _step1Completed = false;
  bool _step2Completed = false;
  bool _step3Completed = false;
  List<UploadFile> uploadedFiles = [];
  GeminiService gem = GeminiService();
  FirebaseDatabase db = FirebaseDatabase();

  void _guardarTema() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      try {
        _db.saveTopic(name);
        _nameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Topic succesfully saved").tr()),
        );
      } catch (e) {
        print("Error en crear el tema $e");
      }
      setState(() {
        _currentStep++;
        _step1Completed = true;
      });
    }
  }

  void nexts() async {
    setState(() {
      _currentStep++;
    });
  }

  void initVariables () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id')!;
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(kToolbarHeight), // Altura estándar del AppBar
          child: AppBar(
            backgroundColor: Color(0xFFFFA500), // Color de fondo del AppBar
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color:
                    theme.iconTheme.color, // Color del ícono basado en el tema
              ),
              onPressed: () {
                Navigator.pop(context); // Regresa a la pantalla anterior
              },
            ),
            title: Stack(
              children: [
                Center(
                  child: Text(
                    'Add Topic',
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(width: kToolbarHeight), // Espacio para alinear el título
            ],
          ),
        ),
        body: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepTapped: null,
            onStepContinue: () {
              if (_currentStep < 3) {
                setState(() => _currentStep += 1);
              } else {
                setState(() => _step3Completed = true);
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              }
            },
            steps: [
              Step(
                title: Text("", style: TextStyle(color: Colors.orange)),
                content: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(20),
                        child: Text(
                          "Add the topic name",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ).tr(),
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a topic name".tr();
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() => _step1Completed = value.isNotEmpty);
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _guardarTema,
                        child: Text("Save".tr()),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 1,
                state: _step1Completed ? StepState.complete : StepState.indexed,
              ),

              Step(
                title: Text("".tr(), style: TextStyle(color: Colors.orange)),
                content: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 400,
                  ),
                  child: FileUploaderScreen(userId: userId,topicId: lastSavedTopicId),
                )

              ),
              Step(
                title: Text(''),
                content: Column(
                  children: <Widget>[
                    Text("What do you want to do?".tr()),
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentStep = 1;
                                _step0Completed = false;
                                _step1Completed = false;
                                _step2Completed = false;
                                _step3Completed = false;
                              });
                            },
                            child: Text("Add other topic".tr()),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.orange,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Menu()),
                              );
                            },
                            child: Text("Exit").tr(),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                isActive: _currentStep >= 3,
                state: _step3Completed ? StepState.complete : StepState.indexed,
              ),
            ],
            controlsBuilder: (BuildContext context, ControlsDetails controls) {
              return SizedBox.shrink();
            },
          ),
        ),
    );
  }
}

class UploadFile {
  final String fileName;
  final String size;
  double progress;
  bool isUploaded;
  File file;

  UploadFile({
    required this.fileName,
    required this.size,
    required this.progress,
    required this.isUploaded,
    required this.file,
  });
}
