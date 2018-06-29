import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/globals.dart' as globals;
import 'package:offerz/ui/theme.dart';
import 'package:offerz/ui/primary_button.dart';
import 'package:offerz/model/user_model.dart';
import 'package:offerz/model/establishment_model.dart';

class EstablishmentPage extends StatefulWidget {
  EstablishmentPage({Key key, this.user, this.firestore}) : super(key: key);

  final Firestore firestore;
  final User user;

  @override
  _EstablishmentPageState createState() => new _EstablishmentPageState();
}

class _EstablishmentPageState extends State<EstablishmentPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  static final formKey = new GlobalKey<FormState>();

  //the form will hydrate this establishment object properly
  static final emptyEstablishment = Map<String, dynamic>();
  EstablishmentModel _establishment =
      EstablishmentModel(null, emptyEstablishment);

  int _saveCount = 0;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    print('validateAndSubmit');
    if (validateAndSave()) {
      // add an establishment to establishment collection
      print('form saved');

      //the proprietor MUST be the email address of the logged in user
      _establishment.proprietor = widget.user.eMail;

      var establishmentMap = _establishment.dataMap;

      // add an establishment (regardless)
      widget.firestore
          .collection('establishments')
          .add(establishmentMap)
          .then((estabRef) {
        print('establishment ${_establishment.name} added');
        //also save to outlets collection of user entry
        var outletData = <String, dynamic>{
          //'name': _establishment.name,
          'establishmentID': estabRef.documentID,
        };
        var userDoc = widget.firestore
            .collection('users')
            .document(_establishment.proprietor);
        var userOutlets = userDoc.collection('outlets');
        userOutlets.add(outletData).whenComplete(() {
          print('outlet added to user ${_establishment.proprietor}');
          setState(() {
            _saveCount++;
          });
        });
      }).catchError((e) => print(e));
    } else {
      print('form did not validate');
    }
  }

  Widget _submitButton() {
    if (_saveCount == 0) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: PrimaryButton(
          key: new Key('submit'),
          text: 'create establishment',
          height: 44.0,
          onPressed: validateAndSubmit,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlatButton(
          color: Colors.green,
          textColor: Colors.white,
          child: Text('Great! next, please set establishment location'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
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
      ),
      key: scaffoldKey,
      backgroundColor: AppThemeColors.main[900],
      body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(children: [
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                _establishment.formFields(_submitButton()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]))),
    );
  }
}
