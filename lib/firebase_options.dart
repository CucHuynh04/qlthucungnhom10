// lib/firebase_options.dart

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAHmlOrLT96dMBHsK1en7ciMVEZluRndl0',
    appId: '1:905772912335:web:79c4ed4f238bffcd4d31ba',
    messagingSenderId: '905772912335',
    projectId: 'flutter-firebase-5592b',
    authDomain: 'flutter-firebase-5592b.firebaseapp.com',
    storageBucket: 'flutter-firebase-5592b.firebasestorage.app',
    databaseURL: 'https://flutter-firebase-5592b-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAHmlOrLT96dMBHsK1en7ciMVEZluRndl0',
    appId: '1:905772912335:android:79c4ed4f238bffcd4d31ba',
    messagingSenderId: '905772912335',
    projectId: 'flutter-firebase-5592b',
    authDomain: 'flutter-firebase-5592b.firebaseapp.com',
    storageBucket: 'flutter-firebase-5592b.firebasestorage.app',
    databaseURL: 'https://flutter-firebase-5592b-default-rtdb.firebaseio.com/',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAHmlOrLT96dMBHsK1en7ciMVEZluRndl0',
    appId: '1:905772912335:ios:79c4ed4f238bffcd4d31ba',
    messagingSenderId: '905772912335',
    projectId: 'flutter-firebase-5592b',
    authDomain: 'flutter-firebase-5592b.firebaseapp.com',
    storageBucket: 'flutter-firebase-5592b.firebasestorage.app',
    databaseURL: 'https://flutter-firebase-5592b-default-rtdb.firebaseio.com/',
    iosBundleId: 'com.example.nhom11_giaodien',
  );
}









