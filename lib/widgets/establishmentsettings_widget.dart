import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:offerz/model/establishment.dart';
import 'package:offerz/ui/primary_button.dart';

class EstablishmentSettingsWidget extends StatefulWidget {
  final Firestore firestore;
  final Establishment establishment;
  final VoidCallback onCompleted;

  EstablishmentSettingsWidget(
      this.firestore, this.establishment, this.onCompleted);

  @override
  State<StatefulWidget> createState() => new EstablishmentSettingsWidgetState();
}

class EstablishmentSettingsWidgetState
    extends State<EstablishmentSettingsWidget> {
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
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: PrimaryButton(
          key: new Key('submit'),
          text: 'Submit',
          height: 44.0,
          onPressed: validateAndSubmit,
        ),
      );
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
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(children: [
              Container(
                child: Text('Set Name, Description & Product category here'),
                decoration:
                    BoxDecoration(color: Color.fromARGB(50, 71, 150, 236)),
              ),
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
