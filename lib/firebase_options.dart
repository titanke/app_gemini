// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDDAapnPYT84yVD9rz8WKlDDacMjO0wxzI',
    appId: '1:200796516226:web:b82181d0c8a9aa78c8a99b',
    messagingSenderId: '200796516226',
    projectId: 'geminitest-32fe1',
    authDomain: 'geminitest-32fe1.firebaseapp.com',
    storageBucket: 'geminitest-32fe1.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAbFSO8qaWjj_Ara8qUHYfVhs2OaIXT4I',
    appId: '1:200796516226:android:97c1a51299c9dd70c8a99b',
    messagingSenderId: '200796516226',
    projectId: 'geminitest-32fe1',
    storageBucket: 'geminitest-32fe1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAmgX0jGEXGz2jVJRDQvNyhAHXPRr6lSSM',
    appId: '1:200796516226:ios:aaaa033e9d2e726ac8a99b',
    messagingSenderId: '200796516226',
    projectId: 'geminitest-32fe1',
    storageBucket: 'geminitest-32fe1.appspot.com',
    iosBundleId: 'com.example.appGemini',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAmgX0jGEXGz2jVJRDQvNyhAHXPRr6lSSM',
    appId: '1:200796516226:ios:aaaa033e9d2e726ac8a99b',
    messagingSenderId: '200796516226',
    projectId: 'geminitest-32fe1',
    storageBucket: 'geminitest-32fe1.appspot.com',
    iosBundleId: 'com.example.appGemini',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDDAapnPYT84yVD9rz8WKlDDacMjO0wxzI',
    appId: '1:200796516226:web:09710121f935773cc8a99b',
    messagingSenderId: '200796516226',
    projectId: 'geminitest-32fe1',
    authDomain: 'geminitest-32fe1.firebaseapp.com',
    storageBucket: 'geminitest-32fe1.appspot.com',
  );

}