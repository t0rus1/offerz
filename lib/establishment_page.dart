import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/globals.dart' as globals;
import 'package:offerz/helpers/utils.dart';
import 'package:offerz/ui/theme.dart';
import 'package:offerz/ui/primary_button.dart';
import 'package:offerz/model/user.dart';
import 'package:offerz/model/establishment.dart';

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

  //the form will hydrate this establishment object
  Establishment _establishment = Establishment();

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

      Map<String, dynamic> establishmentData = <String, dynamic>{
        'address': _establishment.address,
        'country': _establishment.country,
        'description': _establishment.description,
        'latitude': _establishment.latitude,
        'longitude': _establishment.longitude,
        'name': _establishment.name,
        'product-category': _establishment.productCategory,
        'proprietor': _establishment.proprietor,
      };
      // add an establishment (regardless)
      final CollectionReference establishments = widget.firestore.collection('establishments');
      establishments.add(establishmentData).then((docRef) {
        print('establishment ${_establishment.name} added');
        //also save to outlets collection of user entry
        Map<String, dynamic> outletData = <String, dynamic>{
          'name': _establishment.name,
          'establishmentID': docRef.documentID,
        };
        final CollectionReference users = widget.firestore.collection('users');
        final DocumentReference userDoc = users.document(_establishment.proprietor);
        final CollectionReference outlets = userDoc.collection('outlets');
        outlets.add(outletData).whenComplete(() {
          print('outlet added to user ${_establishment.proprietor}');
          setState(() {
            _saveCount++;
          });
        });
      }).catchError((e)=>print(e));

    } else {
      print('form did not validate');
    }
  }

  Widget _submitForSave() {
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

  List<Widget> _establishmentFormFields() {
    return [
      Utils.padded(child: new TextFormField(
        key: new Key('name'),
        decoration: new InputDecoration(labelText: 'Name of establishment'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Name can\'t be empty.' : null,
        onSaved: (val) => _establishment.name = val.trim(),
      )),
      Utils.padded(child: new TextFormField(
        key: new Key('description'),
        decoration: new InputDecoration(labelText: 'Description / Tag line'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Description can\'t be empty.' : null,
        onSaved: (val) => _establishment.description = val.trim(),
      )),
      Utils.padded(child: new TextFormField(
        key: new Key('product category'),
        decoration: new InputDecoration(labelText: 'Product category'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Category can\'t be empty.' : null,
        onSaved: (val) => _establishment.productCategory = val.trim(),
      )),
      Utils.padded(child: new TextFormField(
        key: new Key('address'),
        decoration: new InputDecoration(labelText: 'Street address'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Address can\'t be empty.' : null,
        onSaved: (val) => _establishment.address = val.trim(),
      )),
      Utils.padded(child: new TextFormField(
        key: new Key('country'),
        decoration: new InputDecoration(labelText: 'Country'),
        autocorrect: false,
        initialValue: 'South Africa',          
        validator: (val) => val.isEmpty ? 'Country can\'t be empty.' : null,
        onSaved: (val) => _establishment.country = val.trim(),
      )),
      // Utils.padded(child: new TextFormField(
      //   key: new Key('latitude'),
      //   decoration: new InputDecoration(labelText: 'Latitude'),
      //   autocorrect: false,
      //   initialValue: _latitude, 
      //   validator: (val) => val.isEmpty ? 'Latitude can\'t be empty.' : null,
      //   onSaved: (val) => _latitude = val.trim(),
      // )),
      // Utils.padded(child: new TextFormField(
      //   key: new Key('longitude'),
      //   decoration: new InputDecoration(labelText: 'Longitude'),
      //   autocorrect: false,
      //   initialValue: _longitude, 
      //   validator: (val) => val.isEmpty ? 'Longitude can\'t be empty.' : null,
      //   onSaved: (val) => _longitude = val.trim(),
      // )),
      _submitForSave(),
    ];
  }

  void _locationUpdate(location) {
    print('location updated $location');
    _establishment.latitude = location.latitude;
    _establishment.longitude = location.longitude;
  }

  void _locationUpdateError(e) {
    print('Error $e');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          globals.mobileAppName,
          style: TextStyle(
            color: AppThemeColors.main[50],
            fontSize: 24.0,
          )
        ),
      ),
      key: scaffoldKey,
      backgroundColor: AppThemeColors.main[900],
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0 ),
          child: Column(
            children: [
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
                          children: _establishmentFormFields(),                           
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          )
        )
      ),
    );
  }

}


