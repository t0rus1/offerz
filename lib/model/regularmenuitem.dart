import 'package:flutter/material.dart';
import 'package:offerz/helpers/utils.dart';

class RegularMenuItem {
  //constructor allows creation off a passed in DocumentSnapshot
  RegularMenuItem(String documentID, Map<String, dynamic> fields) {
    this._documentID = documentID;
    name = fields['name'] ?? '';
    description = fields['description'] ?? '';
    category = fields['category'] ?? '';
    price = fields['price'] ?? 0.0;
  }

  String _documentID;
  String get documentID => _documentID;
  set documentID(String documentID) {
    _documentID = documentID;
  }

  String _name;
  String get name => _name;
  set name(String name) {
    _name = name;
  }

  String _description;
  String get description => _description;
  set description(String description) {
    _description = description;
  }

  String _category;
  String get category => _category;
  set category(String category) {
    _category = category;
  }

  double _price;
  double get price => _price;
  set price(double price) {
    _price = price;
  }

  Map<String, dynamic> get dataMap {
    return <String, dynamic>{
      'name': _name,
      'description': _description,
      'category': _category,
      'price': _price,
    };
  }

  List<Widget> formFields(Widget submitButton) {
    return [
      Utils.padded(
          child: new TextFormField(
        key: new Key('name'),
        initialValue: name,
        decoration: new InputDecoration(labelText: 'Item name'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Name can\'t be empty.' : null,
        onSaved: (val) => name = val.trim(),
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('description'),
        initialValue: name,
        decoration: new InputDecoration(labelText: 'Item description'),
        maxLines: 4,
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Description can\'t be empty.' : null,
        onSaved: (val) => description = val.trim(),
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('category'),
        initialValue: name,
        decoration: new InputDecoration(labelText: 'Item category'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Category can\'t be empty.' : null,
        onSaved: (val) => category = val.trim(),
      )),
      Utils.padded(
          child: new TextFormField(
        key: new Key('price'),
        initialValue: name,
        decoration: new InputDecoration(labelText: 'Item price'),
        autocorrect: false,
        validator: (val) {
          double.parse(val) == null ? 'Invalid price' : null;
        },
        onSaved: (val) => price = double.parse(val),
      )),
      submitButton,
    ];
  }
}
