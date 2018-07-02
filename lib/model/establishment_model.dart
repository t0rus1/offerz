import 'package:flutter/material.dart';
import 'package:offerz/helpers/utils.dart';

class EstablishmentModel {
  //constructor allows creation off a passed in DocumentSnapshot
  EstablishmentModel(String documentID, Map<String, dynamic> fields) {
    _documentID = documentID; // can use to find establishment
    _address = fields['address'] ?? '';
    _town = fields['town'] ?? '';
    _city = fields['city'] ?? '';
    _country = fields['country'] ?? '';
    _description = fields['description'] ?? '';
    _latitude = fields['latitude'] ?? '';
    _longitude = fields['longitude'] ?? '';
    _name = fields['name'] ?? '';
    _productCategory = fields['product-category'] ?? '';
    _proprietor = fields['proprietor'] ?? '';
    _what3words = fields['what3words'] ?? '';
    _currency = fields['currency'] ?? '';
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

  String _town;
  String get town => _town;
  set town(String town) {
    _town = town;
  }

  String _city;
  String get city => _city;
  set city(String city) {
    _city = city;
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

  String _what3words;
  String get what3words => _what3words;
  set what3words(String what3words) {
    _what3words = what3words;
  }

  String _currency;
  String get currency => _currency;
  set currency(String currency) {
    _currency = currency;
  }

  Map<String, dynamic> get dataMap {
    return <String, dynamic>{
      'address': _address,
      'town': _town,
      'city': _city,
      'country': _country,
      'description': _description,
      'latitude': _latitude,
      'longitude': _longitude,
      'name': _name,
      'product-category': _productCategory,
      'proprietor': _proprietor,
      'what3words': _what3words,
      'currency': _currency,
    };
  }

  Map<String, dynamic> get localizationMap {
    return <String, dynamic>{
      'latitude': _latitude,
      'longitude': _longitude,
      'town': _town,
      'city': _city,
      'what3words': _what3words,
      'currency': _currency,
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
        enabled: false,
        maxLines: 3,
        initialValue: address,
        decoration: new InputDecoration(labelText: 'Street address'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Address can\'t be empty.' : null,
        onSaved: (val) => address = val.trim(),
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('town'),
        enabled: false,
        initialValue: town,
        decoration: new InputDecoration(labelText: 'Town'),
        autocorrect: false,
        validator: (val) => null,
        onSaved: (val) => town = val.trim(),
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('city'),
        enabled: false,
        initialValue: city,
        decoration: new InputDecoration(labelText: 'City'),
        autocorrect: false,
        validator: (val) => null,
        onSaved: (val) => city = val.trim(),
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('country'),
        enabled: false,
        initialValue: country,
        decoration: new InputDecoration(labelText: 'Country'),
        autocorrect: false,
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('what3words'),
        enabled: false,
        initialValue: what3words,
        decoration: new InputDecoration(labelText: 'what3words'),
        autocorrect: false,
        validator: (val) => null,
        onSaved: (val) => what3words = val.trim(),
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('proprietor'),
        enabled: false,
        initialValue: proprietor,
        decoration: new InputDecoration(labelText: 'Proprietor'),
        autocorrect: false,
      )),
      //submit button with its callback must be provided
      submitButton
    ];
  }
}
