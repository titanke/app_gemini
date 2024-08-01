

import 'package:app_gemini/interfaces/DocumentInterface.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';


const iconsTypes = {
  'application/pdf': Icons.picture_as_pdf,
  'image/jpeg': Icons.image,
  'image/png': Icons.image,
  'text/plain': Icons.insert_drive_file,
};

class FileStorageScreen extends StatefulWidget {
  @override
  _FileStorageScreenState createState() => _FileStorageScreenState();
}

class _FileStorageScreenState extends State<FileStorageScreen> {
  final FirebaseDatabase db = FirebaseDatabase();
  double uploadProgress = 0.0;
  bool isUploading = false;
  bool isEdit = false;

  @override
  Widget build(BuildContext context) {
    final String topicId = ModalRoute
        .of(context)
        ?.settings
        .arguments as String;

    void onDelete(String docId, fileName) async {
      setState(() {
        isUploading = true;
      });

      await db.deleteDocument(topicId, docId, fileName);

      setState(() {
        isUploading = false;
      });
    }

    void onEdit() {
      setState(() {
        isEdit = !isEdit;
      });
    }

    void onAdd() async {
      setState(() {
        isUploading = true;
      });

      await db.pickAndUploadFiles2(topicId, (progress) {
        setState(() {
          print(progress);
          uploadProgress = progress;
        });
      });

      setState(() {
        isUploading = false;
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Documentos'),
          actions: [
            IconButton(onPressed: onEdit,
                icon: Icon(isEdit ? Icons.save : Icons.edit, size: 30,)),
            IconButton(onPressed: onAdd,
                icon: Icon(Icons.add_circle_outline, size: 30,))
          ],
        ),
        body: Stack(
            children: [
              Column(
                children: [
                  /*ElevatedButton(
                onPressed:
                child: Text('Upload File'),
              ),*/

                  Expanded(
                    child: StreamBuilder<List<Document>>(
                      stream: db.loadDocuments(topicId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                              child: Text('No documents uploaded yet'));
                        }

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                          ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            Document doc = snapshot.data![index];
                            return Card(
                              margin: const EdgeInsets.all(16),
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(iconsTypes[lookupMimeType(doc.fileName)]??Icons.insert_drive_file, size: 50),
                                      SizedBox(height: 10),
                                      Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              doc.fileName,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          )
                                      )

                                    ],
                                  ),
                                  if(isEdit)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: IconButton(
                                        icon: Icon(Icons.close, size: 25),
                                        onPressed: () {
                                          onDelete(doc.id, doc.fileName);
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],

              ),
              if (isUploading)
                const Opacity(
                  opacity: 0.8,
                  child: ModalBarrier(dismissible: false, color: Colors.black),
                ),
              if (isUploading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ]
        )
    );
  }
}
