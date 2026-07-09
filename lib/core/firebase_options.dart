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
    apiKey: 'dummy-api-key',
    appId: '1:1234567890:web:1234567890',
    messagingSenderId: 'dummy-sender-id',
    projectId: 'dummy-project-id',
    authDomain: 'dummy-auth-domain',
    storageBucket: 'dummy-storage-bucket',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:1234567890:android:1234567890',
    messagingSenderId: 'dummy-sender-id',
    projectId: 'dummy-project-id',
    storageBucket: 'dummy-storage-bucket',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:1234567890:ios:1234567890',
    messagingSenderId: 'dummy-sender-id',
    projectId: 'dummy-project-id',
    storageBucket: 'dummy-storage-bucket',
    iosBundleId: 'com.example.mealHelper',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:1234567890:ios:1234567890',
    messagingSenderId: 'dummy-sender-id',
    projectId: 'dummy-project-id',
    storageBucket: 'dummy-storage-bucket',
    iosBundleId: 'com.example.mealHelper',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:1234567890:web:1234567890',
    messagingSenderId: 'dummy-sender-id',
    projectId: 'dummy-project-id',
    authDomain: 'dummy-auth-domain',
    storageBucket: 'dummy-storage-bucket',
  );
}
