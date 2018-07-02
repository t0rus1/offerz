import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:offerz/helpers/utils.dart';

import 'package:offerz/model/establishment_model.dart';
import 'package:offerz/model/regularmenuitem_model.dart';
import 'package:offerz/ui/primary_button.dart';
import 'package:offerz/ui/theme.dart';

class RegularMenuItemForm extends StatefulWidget {
  final Firestore firestore;
  final EstablishmentModel establishment;
  final RegularMenuItemModel regularMenuItem;
  final VoidCallback onCompleted;
  final bool areEditing;

  RegularMenuItemForm(this.firestore, this.establishment, this.regularMenuItem,
      this.onCompleted, this.areEditing);

  @override
  _RegularMenuItemWidgetState createState() => _RegularMenuItemWidgetState();
}

class _RegularMenuItemWidgetState extends State<RegularMenuItemForm> {
  static final formKey = new GlobalKey<FormState>();

  Widget _submitButton;
  File _image;
  bool _waitingOnUpload = false;
  bool _postSave = false;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //whether menuitem is new or being updated, we need to ensure the
  //Firebase cloud storage bucket for the image is in sync,
  //since the user may have changed the image
  Future<Map<String, String>> uploadImageToStorage() async {
    Map<String, String> cacheAndCloud = {
      'cacheName': '', // name part (file assumed to be in systemTemp dir)
      'cloudUrl': '' //Firebase storage Url
    };

    //see https://steemit.com/utopian-io/@tensor/using-firestore-storage-and-caching-files-inside-of-dart-s-flutter-framework
    if (_image != null && _image.path != null && _image.path.isNotEmpty) {
      print('_image.path: ${_image.path}');
      ByteData bytes = await rootBundle.load(_image.path);

      //transfer file from its initial location to systemTemp folder (where it is temporarily cached)
      var tmpfileName = "${Random().nextInt(100000)}";
      Directory tmpDir = Directory.systemTemp;
      var tmpfilePath = '${tmpDir.path}/$tmpfileName';
      print('tmpfilePath: $tmpfilePath');
      var file = File(tmpfilePath);
      file.writeAsBytes(bytes.buffer.asInt8List(), mode: FileMode.write);

      //upload to firestore storage
      StorageReference ref = FirebaseStorage.instance.ref().child(tmpfileName);

      StorageUploadTask task = ref.putFile(file);
      Uri downloadUrl = (await task.future).downloadUrl;

      cacheAndCloud['cacheName'] = _image.path; // tmpfileName; //eg 103750
      cacheAndCloud['cloudUrl'] = downloadUrl
          .toString(); // eg https://firebasestorage.googleapis.com/v0/b/offerz-1.appspot.com/o/2701.?alt=media&token=d70b4570-ada5-4245-a179-4641a749e881
    }

    return cacheAndCloud; // the url at which we can retrieve the image from cloud storage
  }

  void validateAndSubmit() async {
    print('validateAndSubmit');
    if (validateAndSave()) {
      print('form saved');
      _waitingOnUpload = true;
      uploadImageToStorage().then((retrievalMap) {
        _waitingOnUpload = false;

        if (retrievalMap['cacheName'].isNotEmpty) {
          //user may have updated the item pic
          widget.regularMenuItem.cacheName = retrievalMap['cacheName'];
        }
        if (retrievalMap['cloudUrl'].isNotEmpty) {
          //user may have updated the item pic
          widget.regularMenuItem.cloudUrl = retrievalMap['cloudUrl'];
        }

        var estabDoc = widget.firestore
            .collection('establishments')
            .document(widget.establishment.documentID);

        //pull new / updated field values into a map
        var menuItemMap = widget.regularMenuItem.dataMap;

        if (widget.regularMenuItem.documentID == 'new') {
          // add an menu item to establishment's menu collection
          estabDoc.collection('menu').add(menuItemMap).whenComplete(() {
            print('saved ${widget.regularMenuItem.name}');
            setState(() {
              _postSave = true;
              _submitButton = buildSubmitButton(_postSave);
            });
            return;
          }).catchError((e) => print(e));
        } else {
          // update the item in firestore
          estabDoc
              .collection('menu')
              .document(widget.regularMenuItem.documentID)
              .setData(menuItemMap, merge: true)
              .whenComplete(() {
            print('saved ${widget.regularMenuItem.name}');
            setState(() {
              _postSave = true;
              _submitButton = buildSubmitButton(_postSave);
            });
            return;
          });
        }
      });
      if (_waitingOnUpload) {
        setState(() {});
      }
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
          color: AppThemeColors.textBackground,
          child: Text(
            'Saved to menu. Tap to return.',
            style: AppThemeText.informOK14,
          ),
          onPressed: widget.onCompleted,
        ),
      );
    } else {
      return Column(
        children: <Widget>[
          PrimaryButton(
            key: Key('submit'),
            text: widget.regularMenuItem.documentID == 'new'
                ? 'Save this NEW item'
                : 'Update this item',
            height: 40.0,
            onPressed: validateAndSubmit,
          ),
          FlatButton(
              padding: EdgeInsets.only(top: 15.0),
              child: Text(
                '<cancel>',
                style: AppThemeText.informOK14,
              ),
              onPressed: widget.onCompleted),
        ],
      );
    }
  }

  Future<Null> selectPhoto() async {
    _image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print('localImagePath (selected photo): ${_image.path}');
  }

  Future<Null> takePhoto() async {
    _image = await ImagePicker.pickImage(source: ImageSource.camera);
    print('localImagePath (newly taken photo): ${_image.path}');
  }

  Column buildForm(bool afterSave) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.regularMenuItem.documentID == 'new'
              ? 'Add an item'
              : 'Edit item',
          style: AppThemeText.norm14,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Form(
            key: formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: afterSave
                    ? widget.regularMenuItem.formFieldsAffirmSave(_submitButton)
                    : widget.regularMenuItem.formFields(
                        _submitButton, _image != null, selectPhoto, takePhoto)),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _submitButton = buildSubmitButton(_postSave);
  }

  @override
  Widget build(BuildContext context) {
    print(
        'build regularmenuitem_form. Image: ${_image == null ? '' : _image.path}');
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Column(children: [
              Card(
                child: _waitingOnUpload
                    ? Utils
                        .waitingIndicator('Please wait, uploading picture...')
                    : buildForm(_postSave),
              ),
            ])));
  }
}
