import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/globals.dart' as globals;
import 'package:offerz/auth.dart';
import 'package:offerz/ui/theme.dart';
import 'package:offerz/model/user.dart';
import 'package:offerz/establishment_page.dart';
import 'package:offerz/setlocation_page.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignOut, this.firestore});
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final Firestore firestore;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //String _signedInEmail;
  User _verifiedUser; // signed in, verified user
  Widget _welcomeWidget;
  Widget _establishmentManagementDrawer;
  Widget _establishmentJoinDrawer;
  Widget _establishmentLocationDrawer;

  Future<User> _retrieveVerifiedUser(String signedInEmail) async {

    //obtain user from cloud firestore (document id the the email)
    CollectionReference users = widget.firestore.collection('users');

    DocumentReference userDoc = users.document(signedInEmail);
    DocumentSnapshot userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      print('user ${userSnapshot.data['email']} retrieved');
      // instantiate our User object (a State variable)
      return User(
        eMail: userSnapshot.data['email'],
        rolePatron: userSnapshot.data['role_proprietor'],
        roleProprietor: userSnapshot.data['role_patron'],
      );
    } else {
      print('Error, failed to retrieve user $signedInEmail');
      // should not happen
      return User(eMail: '', rolePatron: false, roleProprietor: false);
    }
  }

  Widget _buildUnverifiedUserWelcomeWidget() {
    return Card(
      elevation: 2.0,
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 10.0)
          ),
          const ListTile(
            //leading: const Icon(Icons.favorite_border),
            title: const Text(globals.welcomeNewRegistrantTitle),
            subtitle: const Text(globals.welcomeNewRegistrantMessage),
            isThreeLine: true,
          ),
          IconButton(
            tooltip: "Logout",
            color: AppThemeColors.main[700],
            icon: Icon(Icons.exit_to_app),
            iconSize: 40.0,
            onPressed: () => _signOut(),
          ),
          Container(padding: EdgeInsets.only(top: 20.0)),
          Text(
            globals.resendOfferMessage,
          ),
          FlatButton(
            color: AppThemeColors.main[100],
            child: Text('Re-Send verification email'),
            onPressed: () {
              print('request verification email to be sent...');
              widget.auth.sendVerificationMail();
              print('request sent.');
            }
          ),
          Container(
            padding: EdgeInsets.only(top: 10.0)
          ),  
        ]
      )
    );
  }

  // clean login of verified user.
  Widget _buildVerifiedUserWelcomeWidget() {
    print ('_buildVerifiedUserWelcomeWidget');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Stack(
              //alignment: const Alignment(20.0, 20.0),
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: AppThemeColors.main[900],
                  radius: 40.0,
                  child: Icon(
                    Icons.loyalty,
                    size: 60.0,
                    color: AppThemeColors.main[50],
                  ),
                ),
              ],
            ),
            Text('Welcome!',
                style: TextStyle(
                  fontSize: 24.0,
                )),
            Text(
              globals.welcomeBlurbNewSignIn,
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            Text(
              globals.welcomeJoinInstructionsNewSignIn,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            Text(
              globals.welcomeCreateInstructionsNewSignIn,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ]
        ),
       )
    );
  }

  /// build a welcome widget based on whether user is email verified or not
  /// which serves as the Home Page's main content
  Future<void> _buildWelcomeWidget() async {
    print('_buildWelcomeWidget start...');
    bool verified = await widget.auth.userIsVerified();
    if (verified) {
      print('verified');
      String userEmail = await widget.auth.currentUserEmail();
      _verifiedUser = await _retrieveVerifiedUser(userEmail);
      print(_verifiedUser.eMail);
      _welcomeWidget = _buildVerifiedUserWelcomeWidget();
    }
    else {
      print('unverified');
      _welcomeWidget = _buildUnverifiedUserWelcomeWidget();
    }
  }

  Future<int> _userhasOutlets(email) async {

    DocumentReference userDoc;

    userDoc = widget.firestore.collection('users').document(email);
    var snapshot = await userDoc.collection('outlets').getDocuments();
    return snapshot.documents.length;
  }

  Widget _buildEstablishmentManagementDrawer(int numOutlets) {

    if (numOutlets==0) {
      //user has no outlets (establishments) yet,
      return ListTile(
        leading: Icon(
          Icons.create,
          color: AppThemeColors.main[900],
          size: 36.0,
        ),
        title: Text('Create an establishment'),
        subtitle: Text(
          'in order to post your own offers...',
        ),
        onTap: () {
          print('create establishment tapped');
          //Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>  new EstablishmentPage(user: _verifiedUser, firestore: widget.firestore)
            )
          );
        }
      );
    } else {
      return ListTile(
        leading: Icon(
          Icons.subscriptions,
          color: AppThemeColors.main[900],
          size: 36.0,
        ),
        title: Text('Manage my establishment(s)'),
        subtitle:
          Text('you manage $numOutlets outlet(s)'),
        onTap: () {
          print('manage my establishments tapped');
          Navigator.pop(context);
        }
      );
    }
  }

  Widget _buildEstablishmentLocationDrawer(int numOutlets)  {
    if (numOutlets == 0) { 
      return ListTile(
        leading: Icon(
          Icons.pin_drop,
          color: Colors.grey,
          size: 36.0,
        ),
        title: Text('Set establishment location'),
        subtitle: Text(
          'once you\'ve created an establishment...',
        ),
        onTap: () {
          //zippo
        }
      );
    } else {
      return ListTile(
        leading: Icon(
          Icons.pin_drop,
          color: AppThemeColors.main[900],
          size: 36.0,
        ),
        title: Text('Set establishment location'),
        subtitle:
            Text('locate you outlet(s) on the map'),
        onTap: () {
          print('set establishment location tapped');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SetLocationPage(),
            )
          );
        });
    }
  }

  Widget _buildEstablishmentJoinDrawer() {
    return ListTile(
        leading: Icon(
          Icons.add_location,
          color: AppThemeColors.main[900],
          size: 30.0,
        ),
        title: Text('Join an establishment'),
        subtitle: Text('in order to receive offers...'),
        onTap: () {
          print('join establishment tapped');
          Navigator.pop(context);
        });
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    print('enter HomePageState initstate');
    _buildWelcomeWidget().whenComplete(() {
      print('welcomeWidget built');
      _userhasOutlets(_verifiedUser.eMail).then((numOutlets) {
        _establishmentManagementDrawer =_buildEstablishmentManagementDrawer(numOutlets);
        print('managementDrawer built');
        _establishmentJoinDrawer = _buildEstablishmentJoinDrawer();
        print('joinDrawer built');
        _establishmentLocationDrawer =  _buildEstablishmentLocationDrawer(numOutlets);
        print('locationDrawer built');
        setState(() {
          print('setstate for HomePageState');
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(globals.mobileAppName,
            style: TextStyle(
              color: AppThemeColors.main[50],
              fontSize: 24.0,
            )),
        actions: <Widget>[
          FlatButton(
              onPressed: _signOut,
              child: Text('Logout',
                  style: TextStyle(fontSize: 17.0, color: Colors.white)))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, 
          children: <Widget>[
            DrawerHeader(
              child: Text(
                _verifiedUser == null
                ? "${globals.mobileAppName} Main Menu"
                : _verifiedUser.eMail
              ),
              decoration: BoxDecoration(
                color: AppThemeColors.main[400]
              ),
            ),
            _establishmentJoinDrawer,
            _establishmentManagementDrawer,
            _establishmentLocationDrawer,
          ]
        )
      ),
      backgroundColor: AppThemeColors.main[400],
      body: Center(
        child: _welcomeWidget
      )
    );
  }
}
