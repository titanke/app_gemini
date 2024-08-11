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


class FileUploaderScreen extends StatefulWidget {
  String topicId;
  String userId;

  FileUploaderScreen({
    super.key,
    required this.topicId,
    required this.userId,
  });

  @override
  _FileUploaderScreenState createState() => _FileUploaderScreenState();
}

class _FileUploaderScreenState extends State<FileUploaderScreen> {
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
    final String filePath = 'users/${widget.userId}/topics/${widget.topicId}/${uploadFile.fileName}';

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
          .doc(widget.userId)
          .collection('topics')
          .doc(widget.topicId)
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
    String fileTxtPath = 'users/${widget.userId}/topics/${widget.topicId}/';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subir Archivos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Text('Agrega contenido a tu tema subiendo archivos o tomando fotos de tu contenido:'),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _uploadFile,
              child: Container(
                width: double.infinity,
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
                        "Subir Archivos",
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
            Text('o', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            SizedBox(height: 12),

            GestureDetector(
              onTap: _takePhoto,
              child: Container(
                width: double.infinity,
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
                              "Tomar Fotos",
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

            Expanded(
              child: ListView.builder(
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
            ),

            if (uploadedFiles.length>0)
            GestureDetector(
              onTap: _uploadFiles,
              child: Container(
                width: double.infinity,
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
                        "Subir archivos",
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


/*
*
* GestureDetector(
              onTap: _uploadFile,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, color: Colors.blue, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Subir Archivos',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
* */
