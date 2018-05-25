import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/globals.dart' as globals;
import 'package:offerz/root_page.dart';
import 'package:offerz/auth.dart';
import 'package:offerz/ui/theme.dart';

Future<void> main() async { 

  final FirebaseApp app = await FirebaseApp.configure(
    name: 'offerz',
    options: const FirebaseOptions(
      googleAppID: '1:418989884436:android:3ba86b3d24f29140', 
      gcmSenderID: '418989884436',
      apiKey: 'AIzaSyArgmRGfB5kiQT6CunAOmKRVKEsxKmy6YI-G72PVU', // not right, just an example
      projectID: 'offerz-1',
    ),
  );
  final Firestore firestore = new Firestore(app: app);
  
  runApp(new MyApp(firestore: firestore));

}

class MyApp extends StatelessWidget {

  MyApp({this.firestore});
  final Firestore firestore;


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: globals.mobileAppName,
      theme: companyThemeData,
      home: new RootPage(new Auth(), this.firestore),
    );
  }
}
