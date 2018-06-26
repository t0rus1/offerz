import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:offerz/helpers/utils.dart';
import 'package:offerz/ui/theme.dart';
import 'package:offerz/globals.dart' as globals;
import 'package:offerz/special_typedefs.dart';

class RegularMenuItem {
  //constructor allows creation off a passed in DocumentSnapshot
  RegularMenuItem(String documentID, Map<String, dynamic> fields) {
    this._documentID = documentID;
    name = fields['name'] ?? '';
    variant = fields['variant'] ?? '';
    description = fields['description'] ?? '';
    category = fields['category'] ?? '';
    price = fields['price'] ?? 0.0;
    rating = fields['rating'] ?? 0;
    localImagePath = fields['localImagePath'] ?? '';
    storageImageUrl = fields['storageImageUrl'] ?? '';
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

  String _variant;
  String get variant => _variant;
  set variant(String variant) {
    _variant = variant;
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

  int _rating;
  int get rating => _rating;
  set rating(int rating) {
    _rating = rating;
  }

  String _localImagePath;
  String get localImagePath => _localImagePath;
  set localImagePath(String imagePath) {
    _localImagePath = imagePath;
  }

  String _storageImageUrl;
  String get storageImageUrl => _storageImageUrl;
  set storageImageUrl(String storageImageUrl) {
    _storageImageUrl = storageImageUrl;
  }

  Map<String, dynamic> get dataMap {
    return <String, dynamic>{
      'name': _name,
      'description': _description,
      'variant': _variant,
      'category': _category,
      'price': _price,
      'rating': _rating,
      'localImagePath': _localImagePath,
      'storageImageUrl': _storageImageUrl,
    };
  }

  List<Widget> formFields(Widget submitButton,
      NullFutureCallback onPhotoSelected, NullFutureCallback onPhotoTaken) {
    return [
      Utils.padded(
        child: TextFormField(
          key: Key('name'),
          initialValue: name,
          decoration: InputDecoration(labelText: 'Name'),
          autocorrect: false,
          validator: (val) => val.isEmpty ? 'Name can\'t be empty.' : null,
          onSaved: (val) => name = val.trim(),
        ),
      ),
      Utils.padded(
        child: TextFormField(
          key: Key('variant'),
          initialValue: variant,
          decoration: InputDecoration(labelText: 'Size | Variant'),
          maxLines: 1,
          autocorrect: false,
          validator: (val) => null,
          onSaved: (val) => variant = val.trim(),
        ),
      ),
      Utils.padded(
          child: TextFormField(
        key: Key('description'),
        initialValue: description,
        decoration: InputDecoration(labelText: 'Description'),
        maxLines: 3,
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Description can\'t be empty.' : null,
        onSaved: (val) => description = val.trim(),
      )),
      Utils.padded(
          child: TextFormField(
        key: Key('category'),
        initialValue: category,
        decoration: InputDecoration(labelText: 'Category'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Category can\'t be empty.' : null,
        onSaved: (val) => category = val.trim(),
      )),
      Utils.padded(
          child: TextFormField(
        key: Key('price'),
        initialValue: price.toString(),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: 'Price'),
        autocorrect: false,
        validator: (val) {
          double.parse(val) == null ? 'Invalid price' : null;
        },
        onSaved: (val) => price = double.parse(val),
      )),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
        IconButton(
            padding: EdgeInsets.only(bottom: 5.0),
            icon: Icon(
              Icons.add_photo_alternate,
              size: 40.0,
              color: AppThemeColors.main[900],
            ),
            onPressed: onPhotoSelected),
        Text('Select photo'),
        IconButton(
          padding: EdgeInsets.only(bottom: 5.0),
          icon: Icon(
            Icons.add_a_photo,
            size: 40.0,
            color: AppThemeColors.main[900],
          ),
          onPressed: onPhotoTaken,
        ),
        Text('Take photo'),
      ]),
      submitButton
    ];
  }

  /// displays just name, variant and price to affirm the menu item has been saved
  List<Widget> formFieldsAffirmImage(Widget submitButton) {
    return [
      Utils.padded(
        child: TextFormField(
          key: Key('name'),
          initialValue: name,
          decoration: InputDecoration(labelText: 'Name'),
          autocorrect: false,
          validator: (val) => val.isEmpty ? 'Name can\'t be empty.' : null,
          onSaved: (val) => name = val.trim(),
        ),
      ),
      Utils.padded(
        child: TextFormField(
          key: Key('variant'),
          initialValue: variant,
          decoration: InputDecoration(labelText: 'Size | Variant'),
          maxLines: 1,
          autocorrect: false,
          validator: (val) => null,
          onSaved: (val) => variant = val.trim(),
        ),
      ),
      Utils.padded(
          child: TextFormField(
        key: Key('price'),
        initialValue: price.toString(),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: 'Price'),
        autocorrect: false,
        validator: (val) {
          double.parse(val) == null ? 'Invalid price' : null;
        },
        onSaved: (val) => price = double.parse(val),
      )),
      Image.network(
        storageImageUrl,
        fit: BoxFit.contain,
      ),
      submitButton
    ];
  }
}
