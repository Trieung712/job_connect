// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyCOfijDgFOjKSJTPObL01xW5mC6f6y0hJk',
    appId: '1:387272446731:web:09f5ffa18bad6987e7080e',
    messagingSenderId: '387272446731',
    projectId: 'datn-78f14',
    authDomain: 'datn-78f14.firebaseapp.com',
    storageBucket: 'datn-78f14.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFF_E2yvo1kS0TENGwuXt7j52WuSa2Hqc',
    appId: '1:387272446731:android:3c90d206ed9902c0e7080e',
    messagingSenderId: '387272446731',
    projectId: 'datn-78f14',
    storageBucket: 'datn-78f14.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBvKiUH0cVbyEkjljapB6T_xUBoDNQ_NxM',
    appId: '1:387272446731:ios:f9c4d04b48135367e7080e',
    messagingSenderId: '387272446731',
    projectId: 'datn-78f14',
    storageBucket: 'datn-78f14.appspot.com',
    iosBundleId: 'com.example.myApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBvKiUH0cVbyEkjljapB6T_xUBoDNQ_NxM',
    appId: '1:387272446731:ios:f9c4d04b48135367e7080e',
    messagingSenderId: '387272446731',
    projectId: 'datn-78f14',
    storageBucket: 'datn-78f14.appspot.com',
    iosBundleId: 'com.example.myApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCOfijDgFOjKSJTPObL01xW5mC6f6y0hJk',
    appId: '1:387272446731:web:8d46cf35a54b5d04e7080e',
    messagingSenderId: '387272446731',
    projectId: 'datn-78f14',
    authDomain: 'datn-78f14.firebaseapp.com',
    storageBucket: 'datn-78f14.appspot.com',
  );

}