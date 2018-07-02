import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/globals.dart' as globals;
import 'package:offerz/helpers/utils.dart';
import 'package:offerz/pages/root_page.dart';
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
  String _connectivityStatus = 'Unknown';

  Future<ConnectivityResult> _connectivityCheck() async {
    return (new Connectivity().checkConnectivity());
  }

  Widget _decideRootPage() {
    if (_connectivityStatus == 'Unknown') {
      //connectivity check not complete...
      return Utils.waitingIndicator('');
    } else if (_connectivityStatus == 'none') {
      return Container(
        alignment: Alignment(0.0, 0.0),
        color: AppThemeColors.main[400],
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Utils.logoAvatar(20.0),
              FlatButton(
                color: AppThemeColors.main[50],
                child: Text(
                  'Your\'re Offline! Fix & Retry',
                  style: AppThemeText.informOK20,
                ),
                onPressed: () {
                  _doConnectvityTest();
                },
              ),
            ]),
      );
    } else {
      // assume all good
      return RootPage(Auth(), widget.firestore);
    }
  }

  _doConnectvityTest() async {
    _connectivityCheck().then((result) {
      setState(() {
        switch (result) {
          case ConnectivityResult.mobile:
            _connectivityStatus = 'mobile';
            break;
          case ConnectivityResult.wifi:
            _connectivityStatus = 'wifi';
            break;
          default:
            _connectivityStatus = 'none';
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _doConnectvityTest();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: globals.mobileAppName,
        theme: companyThemeData,
        home: _decideRootPage());
  }
}
