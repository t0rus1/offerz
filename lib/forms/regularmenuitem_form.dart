import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:offerz/model/establishment.dart';
import 'package:offerz/model/regularmenuitem.dart';
import 'package:offerz/ui/primary_button.dart';
import 'package:offerz/ui/theme.dart';

class RegularMenuItemWidget extends StatefulWidget {
  final Firestore firestore;
  final Establishment establishment;
  final RegularMenuItem regularMenuItem;
  final VoidCallback onCompleted;

  RegularMenuItemWidget(this.firestore, this.establishment,
      this.regularMenuItem, this.onCompleted);

  @override
  _RegularMenuItemWidgetState createState() => _RegularMenuItemWidgetState();
}

class _RegularMenuItemWidgetState extends State<RegularMenuItemWidget> {
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
      // add an menu item to establishment's menu collection
      print('form saved');
      if (widget.regularMenuItem.documentID == 'new') {
        var estabDoc = widget.firestore
            .collection('establishments')
            .document(widget.establishment.documentID);

        var menuItemMap = widget.regularMenuItem.dataMap;

        var menuDoc =
            estabDoc.collection('menu').add(menuItemMap).whenComplete(() {
          print('saved ${widget.regularMenuItem.name}');
          setState(() {
            _submitButton = buildSubmitButton(true);
          });
        }).catchError((e) => print(e));
      } else {}

      //   var estabDoc = widget.firestore
      //       .collection('establishments')
      //       .document(widget.establishment.documentID);

      //   var establishmentMap = widget.establishment.dataMap;

      //   estabDoc.setData(establishmentMap, merge: true).whenComplete(() {
      //     print('updated ${widget.establishment.name} record');
      //     setState(() {
      //       _submitButton = buildSubmitButton(true);
      //     });
      //   }).catchError((e) => print(e));
      // }
    }
  }

  Widget buildSubmitButton(bool afterSave) {
    if (afterSave) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlatButton(
          child: Text('Saved. Tap to return to menu'),
          onPressed: widget.onCompleted,
        ),
      );
    } else {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: PrimaryButton(
            key: Key('submit'),
            text: 'Submit',
            height: 44.0,
            onPressed: validateAndSubmit,
          ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _submitButton = buildSubmitButton(false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(children: [
              Text(
                  widget.regularMenuItem.documentID == 'new'
                      ? 'NEW menu item'
                      : 'EDIT menu item',
                  style: AppThemeText.norm14),
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
                              widget.regularMenuItem.formFields(_submitButton),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ])));
  }
}
