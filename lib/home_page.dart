import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/globals.dart' as globals;
import 'package:offerz/special_typedefs.dart';
import 'package:offerz/interface/baseauth.dart';
import 'package:offerz/interface/basegeolocation.dart';
import 'package:offerz/ui/theme.dart';
import 'package:offerz/model/user.dart';
import 'package:offerz/establishment_page.dart';
import 'package:offerz/helpers/user_geolocation.dart';
import 'package:offerz/outletlocation_page.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignOut, this.firestore});
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final Firestore firestore;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User _verifiedUser; // signed in, verified user
  Widget _welcomeWidget;
  Widget _establishmentManagementDrawer =
      ListTile(title: Text('management option...'));
  Widget _establishmentJoinDrawer =
      ListTile(title: Text('establishment option...'));

  BaseGeolocation _geolocationProvider = new Geolocater();

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
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(padding: EdgeInsets.only(top: 10.0)),
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
              }),
          Container(padding: EdgeInsets.only(top: 10.0)),
        ]));
  }

  // clean login of verified user.
  Widget _buildVerifiedUserWelcomeWidget() {
    print('_buildVerifiedUserWelcomeWidget');
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
          ]),
    ));
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
    } else {
      print('unverified');
      _welcomeWidget = _buildUnverifiedUserWelcomeWidget();
    }
  }

  // returns a list of establishments (IDs) that the user owns
  Future<List<String>> _getUserOutletIDs(email) async {
    var outletsList = new List<String>();

    var userDoc = widget.firestore.collection('users').document(email);
    var snapshot = await userDoc.collection('outlets').getDocuments();

    for (var item in snapshot.documents) {
      outletsList.add(item.data['establishmentID']);
    }
    return outletsList;
  }

  //this call back is invoked when user confirms his outlet's location
  //it updates the latitude and longitude values in the establishment record
  Future<void> _onOutletLocationConfirmed(
      DocumentSnapshot establishmentSnapshot) async {
    CollectionReference establishments =
        widget.firestore.collection('establishments');
    DocumentReference estabDoc =
        establishments.document(establishmentSnapshot.documentID);

    var updatedData = establishmentSnapshot.data;
    estabDoc.setData(updatedData, merge: true).whenComplete(() {
      print(
          '_onOutletLocationConfirmed: updated lat and long in establishment ${updatedData['name']} record');
      Navigator.of(context).pop();
    }).catchError((e) => print(e));
  }

  Future<ListView> _buildOutletTilesList(List<String> userOutletIDs) async {
    var listEntries = <Widget>[];

    listEntries.add(Container(
      color: AppThemeColors.main[100],
      child:
          Center(child: Text('Your outlets', style: TextStyle(fontSize: 20.0))),
      height: 40.0,
    ));

    var estabs = widget.firestore.collection('establishments');

    for (var ouletId in userOutletIDs) {
      var estabDoc = estabs.document(ouletId);
      var establishmentSnapshot = await estabDoc.get();
      if (establishmentSnapshot != null) {
        listEntries.add(ListTile(
            leading: Icon(
              Icons.restaurant,
              color: AppThemeColors.main[900],
              size: 24.0,
            ),
            title: Text(establishmentSnapshot.data['name']),
            subtitle: Text(
              'if you\'re at this establishment, tap to confirm its location',
              //style: TextStyle(fontSize: 10.0),
            ),
            dense: true,
            enabled: true,
            trailing: Icon(
              Icons.pin_drop,
              color: AppThemeColors.main[900],
              size: 24.0,
            ),
            onTap: () {
              print('${establishmentSnapshot.data['name']} tapped');
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => new OutletLocationPage(
                      _geolocationProvider,
                      establishmentSnapshot,
                      _onOutletLocationConfirmed)));
            }));
      }
    }

    return ListView(
      shrinkWrap: true,
      children: listEntries,
    );
  }

  Future<Widget> _buildEstablishmentManagementDrawer(
      List<String> userOutletIDs) async {
    if (userOutletIDs.length == 0) {
      //user has no outlets (establishments) yet,
      return ListTile(
          leading: Icon(
            Icons.create,
            color: AppThemeColors.main[900],
            size: 32.0,
          ),
          title: Text('Create first establishment'),
          subtitle: Text(
            'so you may post your own special offers...!',
          ),
          onTap: () {
            print('create establishment tapped');
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => new EstablishmentPage(
                    user: _verifiedUser, firestore: widget.firestore)));
          });
    } else {
      return await _buildOutletTilesList(userOutletIDs);
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

  DrawerHeader _drawerHeader() {
    String headerText = "${globals.mobileAppName} Main Menu";
    if (_verifiedUser != null) {
      headerText = "${_verifiedUser.eMail}";
    }
    // if (locationProvider.locationReady) {
    //   headerText += '\nlast known location:';
    //   headerText +=
    //       "\nlat: ${locationProvider.latitude} long: ${locationProvider.longitude}";
    // }
    return DrawerHeader(
      child: Text(
        headerText,
        style: TextStyle(fontSize: 14.0),
      ),
      decoration: BoxDecoration(color: AppThemeColors.main[400]),
    );
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
    print('setDeviceLocation started');
    _geolocationProvider.setDeviceLocation();
    print('enter HomePageState initstate');
    _buildWelcomeWidget().whenComplete(() {
      print('welcomeWidget built');
      _getUserOutletIDs(_verifiedUser.eMail).then((userOutletIds) {
        _buildEstablishmentManagementDrawer(userOutletIds).then((drawer) {
          _establishmentManagementDrawer = drawer;
          print('managementDrawer built');
          _establishmentJoinDrawer = _buildEstablishmentJoinDrawer();
          print('joinDrawer built');
          setState(() {
            print('setstate for HomePageState');
          });
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
            child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          _drawerHeader(),
          _establishmentJoinDrawer,
          _establishmentManagementDrawer,
        ])),
        backgroundColor: AppThemeColors.main[400],
        body: Center(child: _welcomeWidget));
  }
}
