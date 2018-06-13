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
      apiKey:
          'AIzaSyD9tDZ3Vk7HZjt4xpY6-O-gVbAFC8MJucE', // doesn't seem to matter
      projectID: 'offerz-1',
    ),
  );

  //get a firestore instance
  final Firestore firestore = new Firestore(app: app);

  runApp(new MyApp(firestore: firestore));
}

class MyApp extends StatefulWidget {
  MyApp({this.firestore});
  final Firestore firestore;

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: globals.mobileAppName,
      theme: companyThemeData,
      home: new RootPage(new Auth(), widget.firestore),
    );
  }
}
