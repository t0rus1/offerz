import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:offerz/ui/theme.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:offerz/model/establishment.dart';
import 'package:offerz/model/regularmenuitem.dart';
import 'package:offerz/ui/primary_button.dart';
import 'package:offerz/globals.dart' as globals;

class RegularMenuItemForm extends StatefulWidget {
  final Firestore firestore;
  final Establishment establishment;
  final RegularMenuItem regularMenuItem;
  final VoidCallback onCompleted;

  RegularMenuItemForm(this.firestore, this.establishment, this.regularMenuItem,
      this.onCompleted);

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
  Future<String> uploadImageToStorage() async {
    String _cloudUrl = '';

    //see https://steemit.com/utopian-io/@tensor/using-firestore-storage-and-caching-files-inside-of-dart-s-flutter-framework
    if (_image.path != null && _image.path.isNotEmpty) {
      ByteData bytes = await rootBundle.load(_image.path);
      Directory tmpDir = Directory.systemTemp;
      var fileName = "${Random().nextInt(10000)}.";
      var file = File('${tmpDir.path}/$fileName');
      file.writeAsBytes(bytes.buffer.asInt8List(), mode: FileMode.write);

      StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask task = ref.putFile(file);
      Uri downloadUrl = (await task.future).downloadUrl;
      _cloudUrl = downloadUrl.toString();
    }

    return _cloudUrl; // the url at which we can retrieve the image from cloud storage
  }

  void validateAndSubmit() async {
    print('validateAndSubmit');
    if (validateAndSave()) {
      print('form saved');
      _waitingOnUpload = true;
      uploadImageToStorage().then((retrievalUrl) {
        _waitingOnUpload = false;
        widget.regularMenuItem.storageImageUrl = retrievalUrl;
        if (widget.regularMenuItem.documentID == 'new') {
          // add an menu item to establishment's menu collection
          var estabDoc = widget.firestore
              .collection('establishments')
              .document(widget.establishment.documentID);

          var menuItemMap = widget.regularMenuItem.dataMap;

          var menuDoc =
              estabDoc.collection('menu').add(menuItemMap).whenComplete(() {
            print('saved ${widget.regularMenuItem.name}');
            setState(() {
              _postSave = true;
              _submitButton = buildSubmitButton(_postSave);
            });
            return;
          }).catchError((e) => print(e));
        } else {}
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
            'Saved. Tap to return',
            style: AppThemeText.informOK20,
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
                ? 'Save NEW menu item'
                : 'Update menu item',
            height: 40.0,
            onPressed: validateAndSubmit,
          ),
          FlatButton(
              padding: EdgeInsets.only(top: 10.0),
              child: Text('<cancel>'),
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

  @override
  void initState() {
    super.initState();
    _submitButton = buildSubmitButton(_postSave);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Column(children: [
              Card(
                child: _waitingOnUpload
                    ? Container(
                        alignment: Alignment(0.0, 0.0),
                        child: Text('Please wait, uploading picture...'))
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: _postSave
                                      ? widget.regularMenuItem
                                          .formFieldsAffirmImage(_submitButton)
                                      : widget.regularMenuItem.formFields(
                                          _submitButton,
                                          selectPhoto,
                                          takePhoto)),
                            ),
                          ),
                        ],
                      ),
              ),
            ])));
  }
}
