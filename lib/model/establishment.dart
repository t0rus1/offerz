import 'package:flutter/material.dart';
import 'package:offerz/helpers/utils.dart';

class Establishment {
  //constructor allows creation off a passed in DocumentSnapshot
  Establishment(String documentID, Map<String, dynamic> fields) {
    this.documentID = documentID; // can use to find establishment
    address = fields['address'] ?? '';
    country = fields['country'] ?? '';
    description = fields['description'] ?? '';
    latitude = fields['latitude'] ?? '';
    longitude = fields['longitude'] ?? '';
    name = fields['name'] ?? '';
    productCategory = fields['product-category'] ?? '';
    proprietor = fields['proprietor'] ?? '';
  }

  //corresponds to the documentID in the establishments collection
  String _documentID;
  String get documentID => _documentID;
  set documentID(String id) {
    _documentID = id;
  }

  //fields of the establishment document
  String _address;
  String get address => _address;
  set address(String address) {
    _address = address;
  }

  String _country;
  String get country => _country;
  set country(String country) {
    _country = country;
  }

  String _description;
  String get description => _description;
  set description(String description) {
    _description = description;
  }

  String _productCategory;
  String get productCategory => _productCategory;
  set productCategory(String productCategory) {
    _productCategory = productCategory;
  }

  double _latitude;
  double get latitude => _latitude;
  set latitude(double latitude) {
    _latitude = latitude;
  }

  double _longitude;
  double get longitude => _longitude;
  set longitude(double longitude) {
    _longitude = longitude;
  }

  String _name;
  String get name => _name;
  set name(String name) {
    _name = name;
  }

  String _proprietor; // hold email address of the user who is the proprietor
  String get proprietor => _proprietor;
  set proprietor(String proprietor) {
    _proprietor = proprietor;
  }

  Map<String, dynamic> get dataMap {
    return <String, dynamic>{
      'address': _address,
      'country': _country,
      'description': _description,
      'latitude': _latitude,
      'longitude': _longitude,
      'name': _name,
      'product-category': _productCategory,
      'proprietor': _proprietor,
    };
  }

  List<Widget> formFields(Widget submitButton) {
    return [
      Utils.padded(
          child: new TextFormField(
        key: new Key('name'),
        initialValue: name,
        decoration: new InputDecoration(labelText: 'Name of establishment'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Name can\'t be empty.' : null,
        onSaved: (val) => name = val.trim(),
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('description'),
        initialValue: description,
        decoration: new InputDecoration(labelText: 'Description / Tag line'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Description can\'t be empty.' : null,
        onSaved: (val) => description = val.trim(),
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('product category'),
        initialValue: productCategory,
        decoration: new InputDecoration(labelText: 'Product category'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Category can\'t be empty.' : null,
        onSaved: (val) => productCategory = val.trim(),
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('address'),
        initialValue: address,
        decoration: new InputDecoration(labelText: 'Street address'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Address can\'t be empty.' : null,
        onSaved: (val) => address = val.trim(),
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('country'),
        initialValue: country,
        decoration: new InputDecoration(labelText: 'Country'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Country can\'t be empty.' : null,
        onSaved: (val) => country = val.trim(),
      )),
      //submit button with its callback must be provided
      submitButton
    ];
  }
}
