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

class AddTopic extends StatefulWidget {
  @override
  _AddTopicState createState() => _AddTopicState();
}

class _AddTopicState extends State<AddTopic> {
  final _formKey = GlobalKey<FormState>();
  bool _isUploading = false;
  final TextEditingController _nameController = TextEditingController();
  final FirebaseDatabase _db = FirebaseDatabase();
  int _currentStep = 0;
  bool _step0Completed = false;
  bool _step1Completed = false;
  bool _step2Completed = false;
  bool _step3Completed = false;
  List<UploadFile> uploadedFiles = [];
  bool _isLoadingCamera = false;
  bool _isLoadingFile = false;
  bool _isLoadingUpload = false;
  GeminiService gem = GeminiService();
  FirebaseDatabase db = FirebaseDatabase();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _uploadFile() async {
    setState(() {
      _isLoadingFile = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: true,
    );

    if (result != null) {
      for (var file in result.files) {
        uploadedFiles.add(UploadFile(
          fileName: file.name,
          size: "${file.size/1000} KB",
          progress: 0.0,
          isUploaded: false,
          file: File(file.path!),
        ));
      }
    }

    setState(() {
      _isLoadingFile = false;
    });
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isLoadingCamera = true;
    });

    final ImagePicker _picker = ImagePicker();

    XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (photo != null) {
      File file = File(photo.path);
      uploadedFiles.add(UploadFile(
        fileName: photo.name,
        size: "${file.lengthSync() / 1000} KB",
        progress: 0.0,
        isUploaded: false,
        file: file,
      ));
    }

    setState(() {
      _isLoadingCamera = false;
    });
  }

  Future<void> _uploadFileFir(UploadFile uploadFile, Function(String) onContentReceived) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final String filePath = 'users/$userId/topics/$lastSavedTopicId/${uploadFile.fileName}';

    try {
      final uploadTask = _storage.ref(filePath).putFile(uploadFile.file);

      uploadTask.snapshotEvents.listen((taskSnapshot) {
        double progress = taskSnapshot.bytesTransferred.toDouble() / taskSnapshot.totalBytes.toDouble();
        setState(() {
          uploadFile.progress = progress;
        });
      });

      await uploadTask;

      String downloadURL = await _storage.ref(filePath).getDownloadURL();

      DocumentReference docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('topics')
          .doc(lastSavedTopicId)
          .collection('documents')
          .doc();

      await docRef.set({
        'fileName': uploadFile.fileName,
        'url': downloadURL,
        'uploadedAt': Timestamp.now(),
      });

      String transcriptContent = await gem.transcriptDocument(uploadFile.file, downloadURL);
      String documentId = docRef.id;

      final markdownContent = '======$documentId\n$transcriptContent\n======$documentId';
      onContentReceived(markdownContent);

      setState(() {
        uploadFile.isUploaded = true;
      });

      showToast(message: "File saved".tr());
    } catch (e) {
      showToast(message: "${"Error in save document".tr()} $e");
      print(e);
    }
  }

  Future<void> _uploadFiles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    String fileTxtPath = 'users/$userId/topics/$lastSavedTopicId/';
    setState(() {
      _isLoadingUpload = true;
    });

    final List<Future<void>> uploadTasks = [];
    List<String> markdownContents = [];

    for (var uploadFile in uploadedFiles) {
      final uploadTask = _uploadFileFir(uploadFile, (content) {
        markdownContents.add(content);
      });
      uploadTasks.add(uploadTask);
    }

    await Future.wait(uploadTasks);

    final combinedMarkdownContent = markdownContents.join('\n');

    await db.SaveTranscript(combinedMarkdownContent, fileTxtPath);

    setState(() {
      _isLoadingUpload = false;
    });
    Navigator.pop(context);
  }
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

  void _handleFileUpload() async {
    setState(() {
      _isUploading = true;
    });

    try {
      await _db.pickAndUploadFiles2(lastSavedTopicId);
      setState(() {
        _step2Completed = true;
        _currentStep++;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading file").tr()),
        );
      });
    }
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
        body: Form(
          key: _formKey,
          child: Stepper(
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
                content: Column(
                  children: [
            Text('Add your topic notes (PDF/Pictures)'),
            SizedBox(height: 20),
          
            GestureDetector(
                        onTap: _uploadFile,
                        child: Container(
                          /*width: double.infinity,*/
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: _isLoadingFile
                                ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  "Upload from your device",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
              SizedBox(height: 12),
            Text('Or', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            SizedBox(height: 12),

            GestureDetector(
              onTap: _takePhoto,
              child: Container(
                /*width: double.infinity,*/
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: _isLoadingCamera
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              "Take a Picture",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                ),
              ),
            ),

            SizedBox(height: 20),

           ListView.builder(
            shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                itemCount: uploadedFiles.length,
                itemBuilder: (context, index) {
                  final file = uploadedFiles[index];
                  return ListTile(
                    
                    leading: Icon(Icons.insert_drive_file, color: Colors.black),
                    title: Text(file.fileName),
                    subtitle: file.isUploaded
                        ? Text('${file.size} - Uploaded',
                            style: TextStyle(color: Colors.green))
                        : LinearProgressIndicator(value: file.progress),
                    trailing: file.isUploaded
                        ? Icon(Icons.check, color: Colors.green)
                        : Text('${(file.progress * 100).toStringAsFixed(0)}%'),
                  );
                },
              ),
            

            if (uploadedFiles.length>0)
            GestureDetector(
              onTap: _uploadFiles,
              child: Container(
                /*width: double.infinity,*/
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: _isLoadingUpload
                      ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Save Notes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
        
                  ],
                ),
                isActive: _currentStep >= 2,
                state: _step2Completed ? StepState.complete : StepState.indexed,
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
