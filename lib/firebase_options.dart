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
    apiKey: 'AIzaSyCNYATU4PEKrt5GTsKMRP_s6ia-gmcgaj8',
    appId: '1:739611103226:web:1f6748365f212a8e185e43',
    messagingSenderId: '739611103226',
    projectId: 'banker-dc808',
    authDomain: 'banker-dc808.firebaseapp.com',
    databaseURL: 'https://banker-dc808-default-rtdb.firebaseio.com',
    storageBucket: 'banker-dc808.appspot.com',
    measurementId: 'G-GN4E8X7R94',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjA_nromfPAmlosJdrzUht_i9rHuKpGoM',
    appId: '1:739611103226:android:335b4b736a370018185e43',
    messagingSenderId: '739611103226',
    projectId: 'banker-dc808',
    databaseURL: 'https://banker-dc808-default-rtdb.firebaseio.com',
    storageBucket: 'banker-dc808.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD-nkZNRpRDV2HeS1b1SPMTxCSJ86Ty4s4',
    appId: '1:739611103226:ios:4e4333f7999ae776185e43',
    messagingSenderId: '739611103226',
    projectId: 'banker-dc808',
    databaseURL: 'https://banker-dc808-default-rtdb.firebaseio.com',
    storageBucket: 'banker-dc808.appspot.com',
    androidClientId: '739611103226-d68idgs880t9gia68m79t2h83bm5kpbb.apps.googleusercontent.com',
    iosClientId: '739611103226-scmgpppev9alq728bkgmposv0td90p0b.apps.googleusercontent.com',
    iosBundleId: 'com.example.bankedzw',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD-nkZNRpRDV2HeS1b1SPMTxCSJ86Ty4s4',
    appId: '1:739611103226:ios:4e4333f7999ae776185e43',
    messagingSenderId: '739611103226',
    projectId: 'banker-dc808',
    databaseURL: 'https://banker-dc808-default-rtdb.firebaseio.com',
    storageBucket: 'banker-dc808.appspot.com',
    androidClientId: '739611103226-d68idgs880t9gia68m79t2h83bm5kpbb.apps.googleusercontent.com',
    iosClientId: '739611103226-scmgpppev9alq728bkgmposv0td90p0b.apps.googleusercontent.com',
    iosBundleId: 'com.example.bankedzw',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCNYATU4PEKrt5GTsKMRP_s6ia-gmcgaj8',
    appId: '1:739611103226:web:1f6748365f212a8e185e43',
    messagingSenderId: '739611103226',
    projectId: 'banker-dc808',
    authDomain: 'banker-dc808.firebaseapp.com',
    databaseURL: 'https://banker-dc808-default-rtdb.firebaseio.com',
    storageBucket: 'banker-dc808.appspot.com',
    measurementId: 'G-GN4E8X7R94',
  );

}