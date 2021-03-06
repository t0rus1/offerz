import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/globals.dart' as globals;
import 'package:offerz/helpers/utils.dart';
import 'package:offerz/model/establishment_model.dart';
import 'package:offerz/interface/baseauth.dart';
import 'package:offerz/ui/theme.dart';
import 'package:offerz/model/user_model.dart';
import 'package:offerz/forms/establishment_form.dart';
import 'package:offerz/pages/establishment_home_page.dart';

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
  Widget _drawerHead;
  Widget _establishmentManagementDrawer;
  Widget _establishmentJoinDrawer;
  bool _starting = true;

  Future<User> _getVerifiedUser(String signedInEmail) async {
    print('_getVerifiedUser($signedInEmail)');
    //obtain user from cloud firestore (document id the the email)
    CollectionReference users = widget.firestore.collection('users');

    DocumentReference userDoc = users.document(signedInEmail);
    DocumentSnapshot userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      print('user ${userSnapshot.data['email']} retrieved from firesstore');
      // instantiate our User object (a State variable)
      return User(
        eMail: userSnapshot.data['email'],
        rolePatron: userSnapshot.data['role_proprietor'],
        roleProprietor: userSnapshot.data['role_patron'],
      );
    } else {
      print('Error, failed to retrieve user $signedInEmail from firestore');
      // should not happen
      return User(eMail: '', rolePatron: false, roleProprietor: false);
    }
  }

  Widget _unverifiedWelcome() {
    print('_unverifiedWelcome()');
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
  Widget _verifiedWelcome() {
    print('_verifiedWelcome()');
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Utils.logoAvatar(20.0),
            Text('Welcome!', style: AppThemeText.norm24),
            Text(globals.welcomeBlurbNewSignIn, style: AppThemeText.norm20),
            Text(globals.welcomeJoinInstructionsNewSignIn,
                style: AppThemeText.norm16),
            Text(globals.welcomeCreateInstructionsNewSignIn,
                style: AppThemeText.norm16),
          ]),
    ));
  }

  // build a welcome widget based on whether user is email verified or not
  // which serves as the Home Page's main content
  Future<void> _welcome() async {
    print('_welcome()');
    bool verified = await widget.auth.userIsVerified();
    if (verified) {
      print('verified');
      String userEmail = await widget.auth.currentUserEmail();
      _verifiedUser = await _getVerifiedUser(userEmail);
      print(_verifiedUser.eMail);
      _welcomeWidget = _verifiedWelcome();
    } else {
      print('unverified');
      _welcomeWidget = _unverifiedWelcome();
    }
  }

  // returns a list of establishments (IDs) that the user owns
  Future<List<String>> _getUserOutletIDs(email) async {
    print('_getUserOutletIDs($email)');
    var outletsList = new List<String>();

    var userDoc = widget.firestore.collection('users').document(email);
    var snapshot = await userDoc.collection('outlets').getDocuments();

    for (var item in snapshot.documents) {
      outletsList.add(item.data['establishmentID']);
    }
    print('${outletsList.length} outlets found');

    return outletsList;
  }

  //this call back is invoked when user confirms his outlet's location
  //it updates the latitude and longitude values in the establishment record
  Future<void> _onOutletLocated(EstablishmentModel establishment) async {
    print('_onOutletLocated()');

    var estabDoc = widget.firestore
        .collection('establishments')
        .document(establishment.documentID);

    estabDoc.setData(establishment.localizationMap).whenComplete(() {
      print('updated localization in ${establishment.name} record');
    }).catchError((e) => print(e));
  }

  //build list of outlets for current user
  Future<ListView> _outletTilesList(List<String> establishmentIDs) async {
    print('_outletTilesList()');
    var listEntries = <Widget>[];

    if (establishmentIDs.length > 0) {
      listEntries.add(Container(
        color: AppThemeColors.main[100],
        child: Center(
            child: Text('Your Own Establishments',
                style: TextStyle(fontSize: 20.0))),
        height: 40.0,
      ));
    }

    var estabsCollection = widget.firestore.collection('establishments');

    for (var estabId in establishmentIDs) {
      var estabDoc = estabsCollection.document(estabId);
      var estabShot = await estabDoc.get();
      if (estabShot != null) {
        var establishment =
            EstablishmentModel(estabShot.documentID, estabShot.data);
        bool notLocated =
            establishment.latitude == null || establishment.longitude == null;

        listEntries.add(ListTile(
            leading: Icon(
              Icons.restaurant,
              color: AppThemeColors.main[900],
              size: 24.0,
            ),
            title: Text(establishment.name),
            subtitle:
                Text(notLocated ? 'not yet located' : establishment.address),
            dense: true,
            enabled: true,
            trailing: Icon(
              notLocated ? Icons.add_alert : Icons.done,
              color: AppThemeColors.main[900],
              size: 24.0,
            ),
            onTap: () {
              print('${establishment.name} tapped');
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      EstablishmentHomePage(widget.firestore, establishment)));
            }));
      }
    }

    return ListView(
      shrinkWrap: true,
      children: listEntries,
    );
  }

  Future<Widget> _estabMngmntDrawer(List<String> userOutletIDs) async {
    print('_estabMngmntDrawer()');
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
      return await _outletTilesList(userOutletIDs);
    }
  }

  Widget _estabJoinDrawer() {
    print('_estabJoinDrawer()');
    return ListTile(
        leading: Icon(
          Icons.add_location,
          color: AppThemeColors.main[900],
          size: 30.0,
        ),
        title: Text('nearby establishments'),
        subtitle: Text('for you to link with...'),
        onTap: () {
          print('join establishment tapped');
          Navigator.pop(context);
        });
  }

  DrawerHeader _drawerHeader() {
    print('_drawerHeader()');
    String headerText = "${globals.mobileAppName} Main Menu";
    if (_verifiedUser != null) {
      headerText = "${_verifiedUser.eMail}";
    }
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

    print('HomePageState initState()');

    _welcome().whenComplete(() {
      _getUserOutletIDs(_verifiedUser.eMail).then((userOutletIds) {
        _estabMngmntDrawer(userOutletIds).then((mngmntDrawer) {
          setState(() {
            _starting = false;
            _drawerHead = _drawerHeader();
            _establishmentManagementDrawer = mngmntDrawer;
            _establishmentJoinDrawer = _estabJoinDrawer();
            print('setState() for HomePageState');
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('building...');
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
          _drawerHead,
          _establishmentJoinDrawer,
          _establishmentManagementDrawer,
        ])),
        backgroundColor: AppThemeColors.main[400],
        body: _starting
            ? Utils.waitingIndicator('')
            : Center(child: _welcomeWidget));
  }
}
