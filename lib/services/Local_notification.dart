import "package:firebase_messaging/firebase_messaging.dart";

class Fnoti {
  final _fm = FirebaseMessaging.instance;

  Future<void> initNotific() async{
    await _fm.requestPermission();
    final fcmToken = await _fm.getToken();
  print("hola: "'$fcmToken');
  }
}