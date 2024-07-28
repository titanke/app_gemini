import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String fileName;
  final String url;
  final DateTime uploadedAt;

  Document({
    required this.fileName,
    required this.url,
    required this.uploadedAt,
  });

  factory Document.fromFirestore(DocumentSnapshot doc) {
    return Document(
      fileName: doc['fileName'],
      url: doc['url'],
      uploadedAt: (doc['uploadedAt'] as Timestamp).toDate(),
    );
  }
}