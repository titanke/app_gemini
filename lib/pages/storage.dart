import 'package:flutter/material.dart';
/*
import 'package:firebase_storage/firebase_storage.dart';

class StoragePage extends StatefulWidget {
  final String storagePath;

  StoragePage({required this.storagePath});

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  
  List<Reference> _files = []; // List to store file references

  @override
  void initState() {
    super.initState();
    _listFiles(); // Fetch file list on initialization
  }

  Future<void> _listFiles() async {
    final storage = FirebaseStorage.instance.ref(widget.storagePath); // Reference to storage location
    final result = await storage.listAll();
    setState(() {
      _files = result.items; // Update state with fetched files
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archivos almacenados: ${widget.storagePath}'),
      ),
      body: _files.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
          : GridView.count(
              crossAxisCount: 2, // Two items per row
              children: _files.map((fileRef) {
                return _buildFileItem(fileRef); // Build widget for each file
              }).toList(),
            ),
    );
  }

  Widget _buildFileItem(Reference fileRef) {
    return FutureBuilder<Metadata>(
      future: fileRef.getMetadata(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final metadata = snapshot.data!;
          return InkWell(
            onTap: () => _downloadFile(fileRef), // Handle file tap
            child: GridTile(
              child: Stack(
                children: [
                  // Display placeholder for now, customize based on file type
                  Center(child: Icon(Icons.file_generic)),
                  if (metadata.contentType?.startsWith('image/') == true)
                    // Add image preview if it's an image
                    FutureBuilder<Url>(
                      future: fileRef.getDownloadURL(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        }
                        return Container();
                      },
                    )
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return CircularProgressIndicator(); // Show loading indicator while fetching metadata
      },
    );
  }

  Future<void> _downloadFile(Reference fileRef) async {
    final url = await fileRef.getDownloadURL();
    // Implement download logic using url or external libraries (optional)
    print('File URL: $url');
  }
}
*/