// File: lib/firebase_options.dart
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb)
    {
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
    apiKey: 'AIzaSyC-cQBDTRYCADE745YCqXEyDq4vk78Xptc',
    appId: '1:209955536387:web:5c11f4f16131acb9f2d836',
    messagingSenderId: '209955536387',
    projectId: 'foodmanagement-2025',
    authDomain: 'foodmanagement-2025.firebaseapp.com',
    storageBucket: 'foodmanagement-2025.firebasestorage.app',
    measurementId: 'G-P9NWJNE0RE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBhHpGZ5OYxjmsh342i0PXkh8gAUqbVXEM',
    appId: '1:209955536387:android:eb32e8b0e406fa5df2d836',
    messagingSenderId: '209955536387',
    projectId: 'foodmanagement-2025',
    storageBucket: 'foodmanagement-2025.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_rVgliI49d3g8_tpEvdXH-QtErX9AxFQ',
    appId: '1:209955536387:ios:c6c5856aa2c0cb2af2d836',
    messagingSenderId: '209955536387',
    projectId: 'foodmanagement-2025',
    storageBucket: 'foodmanagement-2025.firebasestorage.app',
    iosBundleId: 'com.example.project',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_rVgliI49d3g8_tpEvdXH-QtErX9AxFQ',
    appId: '1:209955536387:ios:c6c5856aa2c0cb2af2d836',
    messagingSenderId: '209955536387',
    projectId: 'foodmanagement-2025',
    storageBucket: 'foodmanagement-2025.firebasestorage.app',
    iosBundleId: 'com.example.project',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC-cQBDTRYCADE745YCqXEyDq4vk78Xptc',
    appId: '1:209955536387:web:edcb9f73a4a45baef2d836',
    messagingSenderId: '209955536387',
    projectId: 'foodmanagement-2025',
    authDomain: 'foodmanagement-2025.firebaseapp.com',
    storageBucket: 'foodmanagement-2025.firebasestorage.app',
    measurementId: 'G-920YB335F9',
  );

}