import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/globals.dart' as globals;
import 'package:offerz/interface/baseauth.dart';
import 'package:offerz/login_page.dart';
import 'package:offerz/home_page.dart';

class RootPage extends StatefulWidget {
  final BaseAuth auth;
  final Firestore firestore;

  RootPage(this.auth, this.firestore, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn,
}


class _RootPageState extends State<RootPage> {
  CollectionReference get users => widget.firestore.collection('users');

  AuthStatus authStatus = AuthStatus.notSignedIn;

  initState() {
    super.initState();    
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus =
            userId != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
      });
    });    
  }

  //Add to users collection in cloud firestore
  //and send verification email
  _addUser(String email) async {
    DocumentReference userDoc = users.document('$email');

    Map<String, dynamic> userData = <String, dynamic>{
      'email': email,
      'role_patron': false,  // gets set when user is linked to his first establishment
      'role_proprietor': false, // gets set when user becomes a proprietor
    };
    userDoc.setData(userData, merge: false).whenComplete(() {
      print('user $email added to cloud firestore');
      widget.auth.sendVerificationMail().whenComplete(() {
        print('verification email sent');
        setState(() {
          authStatus = AuthStatus.signedIn;
        });
      }).catchError((e) => print(e));
    }).catchError((e) => print(e));
  }

  void _updateAuthStatus(AuthStatus status) {
    setState(() {
      authStatus = status;
    });
  }

  void _registeredNewUser(String email) {
    print('new registration from $email');
    _addUser(email);
  }

  @override
  Widget build(BuildContext context) {

    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          title: globals.mobileAppName,
          auth: widget.auth,
          onSignIn: () => _updateAuthStatus(AuthStatus.signedIn),
          onRegister: (String email) => _registeredNewUser(email),
        );
      case AuthStatus.signedIn:
        return new HomePage(
            auth: widget.auth,
            onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn),
            firestore: widget.firestore
        );
    }
  }


}
