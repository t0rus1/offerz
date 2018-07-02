import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:offerz/model/establishment_model.dart';
import 'package:offerz/ui/primary_button.dart';
import 'package:offerz/ui/theme.dart';

class EstablishmentSettingsForm extends StatefulWidget {
  final Firestore firestore;
  final EstablishmentModel establishment;
  final VoidCallback onCompleted;

  EstablishmentSettingsForm(
      this.firestore, this.establishment, this.onCompleted);

  @override
  State<StatefulWidget> createState() => new EstablishmentSettingsWidgetState();
}

class EstablishmentSettingsWidgetState
    extends State<EstablishmentSettingsForm> {
  static final formKey = new GlobalKey<FormState>();
  Widget _submitButton;

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

      var estabDoc = widget.firestore
          .collection('establishments')
          .document(widget.establishment.documentID);

      var establishmentMap = widget.establishment.dataMap;

      estabDoc.setData(establishmentMap, merge: true).whenComplete(() {
        print('updated ${widget.establishment.name} record');
        setState(() {
          _submitButton = buildSubmitButton(true);
        });
      }).catchError((e) => print(e));
    }
  }

  Widget buildSubmitButton(bool afterSave) {
    if (afterSave) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlatButton(
          child: Text('Profile saved. Tap for Home Card'),
          onPressed: widget.onCompleted,
        ),
      );
    } else {
      return Column(children: <Widget>[
        PrimaryButton(
          key: new Key('submit'),
          text: 'Submit',
          height: 44.0,
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          padding: EdgeInsets.only(top: 15.0),
          child: Text(
            '<cancel>',
            style: AppThemeText.informOK14,
          ),
          onPressed: widget.onCompleted,
        )
      ]);
    }
  }

  @override
  void initState() {
    super.initState();
    _submitButton = buildSubmitButton(false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(2.0),
            child: Column(children: [
              Text(
                  '(Note: some settings are auto filled by the establishment\'s Set Location option)',
                  style: AppThemeText.light14),
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
                              widget.establishment.formFields(_submitButton),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ])));
  }
}
