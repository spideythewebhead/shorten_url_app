import 'package:firebase_core/firebase_core.dart';

abstract class FirebaseConfig {
  static const android = FirebaseOptions(
    apiKey: 'AIzaSyCWpFX-XvaBnAArpQz3oBXIEWg6M3ud9Qw',
    appId: '1:511103754996:android:44222f90da11a4d922f4a1',
    messagingSenderId: '',
    projectId: 'shorten-url-e74af',
    storageBucket: 'shorten-url-e74af.appspot.com',
    androidClientId:
        '511103754996-7cbdiimaap79igik0h6qsg3rd2a09u6q.apps.googleusercontent.com',
  );
}

const kEmulatorsIp = String.fromEnvironment(
  'emulators_ip',
  defaultValue: '',
);
