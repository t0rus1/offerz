import 'package:flutter/material.dart';
import 'package:offerz/helpers/utils.dart';
import 'package:offerz/ui/theme.dart';
import 'package:offerz/special_typedefs.dart';

class RegularMenuItemModel {
  //constructor allows creation off a passed in DocumentSnapshot
  RegularMenuItemModel(String documentID, Map<String, dynamic> fields) {
    this._documentID = documentID;
    name = fields['name'] ?? '';
    code = fields['code'] ?? '';
    variant = fields['variant'] ?? '';
    description = fields['description'] ?? '';
    category = fields['category'] ?? '';
    price = fields['price'] ?? '';
    rating = fields['rating'] ?? 0;
    cacheName = fields['cacheName'] ?? '';
    cloudUrl = fields['cloudUrl'] ?? '';
  }

  String _documentID;
  String get documentID => _documentID;
  set documentID(String val) {
    _documentID = val;
  }

  String _name;
  String get name => _name;
  set name(String val) {
    _name = val;
  }

  String _code;
  String get code => _code;
  set code(String code) {
    _code = code;
  }

  //can hold more than one variant, as long as separated by '|'
  String _variant;
  String get variant => _variant;
  set variant(String val) {
    _variant = val;
  }

  String _description;
  String get description => _description;
  set description(String val) {
    _description = val;
  }

  String _category;
  String get category => _category;
  set category(String val) {
    _category = val;
  }

  //can hold more than one price, as long as separated by '|'
  String _price;
  String get price => _price;
  set price(String val) {
    _price = val;
  }

  int _rating;
  int get rating => _rating;
  set rating(int val) {
    _rating = val;
  }

  String _cacheName;
  String get cacheName => _cacheName;
  set cacheName(String val) {
    _cacheName = val;
  }

  String _cloudUrl;
  String get cloudUrl => _cloudUrl;
  set cloudUrl(String val) {
    _cloudUrl = val;
  }

  Map<String, dynamic> get dataMap {
    return <String, dynamic>{
      'name': _name,
      'code': _code,
      'description': _description,
      'variant': _variant,
      'category': _category,
      'price': _price,
      'rating': _rating,
      'cacheName': _cacheName,
      'cloudUrl': _cloudUrl,
    };
  }

  _validatePrices(String value) {
    if (value.isEmpty) {
      return 'Must contain at least one price';
    }
    String p = "[0-9\.\/]+";
    RegExp regExp = new RegExp(p);
    if (regExp.hasMatch(value)) {
      return null; //all good
    }
    return "May only contain numbers separated by '/' ";
  }

  Widget _galleryOrCameraButtonBar(
      NullFutureCallback onPhotoSelected, NullFutureCallback onPhotoTaken) {
    var btnBar =
        ButtonBar(alignment: MainAxisAlignment.start, children: <Widget>[
      IconButton(
          padding: EdgeInsets.only(bottom: 5.0),
          icon: Icon(
            Icons.add_photo_alternate,
            size: 40.0,
            color: AppThemeColors.main[900],
          ),
          onPressed: onPhotoSelected),
      Text('from\ngallery'),
      IconButton(
        padding: EdgeInsets.only(bottom: 5.0),
        icon: Icon(
          Icons.add_a_photo,
          size: 40.0,
          color: AppThemeColors.main[900],
        ),
        onPressed: onPhotoTaken,
      ),
      Text('use\ncamera'),
    ]);
    return Column(
      children: <Widget>[
        btnBar,
        _picReminder(),
      ],
    );
  }

  Widget _picReminder() {
    return Container(
        padding: EdgeInsets.only(bottom: 5.0),
        alignment: Alignment(0.0, 0.0),
        child: Text('(change existing product pic using buttons above)'));
  }

  Widget _picChosenAffirmation() {
    return Container(
        padding: EdgeInsets.only(bottom: 5.0),
        alignment: Alignment(0.0, 0.0),
        child: Text('(chosen picture will be included)'));
  }

  List<Widget> formFields(Widget submitButton, bool picChosen,
      NullFutureCallback onPhotoSelected, NullFutureCallback onPhotoTaken) {
    return [
      Utils.padded(
        child: TextFormField(
          key: Key('name'),
          initialValue: name,
          autofocus: true,
          decoration: InputDecoration.collapsed(
              hintText: 'Name', border: UnderlineInputBorder()),
          autocorrect: false,
          validator: (val) => val.isEmpty ? 'Name can\'t be empty.' : null,
          onSaved: (val) => name = val.trim(),
        ),
      ),
      Utils.padded(
          child: TextFormField(
        key: Key('description'),
        initialValue: description,
        decoration: InputDecoration.collapsed(
            hintText: 'Description', border: UnderlineInputBorder()),
        maxLines: 3,
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Description can\'t be empty.' : null,
        onSaved: (val) => description = val.trim(),
      )),
      Row(children: <Widget>[
        Flexible(
          child: Utils.padded(
              child: TextFormField(
            key: Key('category'),
            initialValue: category,
            decoration: InputDecoration.collapsed(
                hintText: 'Category', border: UnderlineInputBorder()),
            autocorrect: false,
            validator: (val) => null,
            onSaved: (val) => category = val.trim(),
          )),
        ),
        Flexible(
          child: Utils.padded(
              child: TextFormField(
            key: Key('code'),
            initialValue: code,
            decoration: InputDecoration.collapsed(
                hintText: 'Code', border: UnderlineInputBorder()),
            autocorrect: false,
            validator: (val) => null,
            onSaved: (val) => code = val.trim(),
          )),
        ),
      ]),
      Utils.padded(
        child: TextFormField(
          key: Key('variant'),
          initialValue: variant,
          decoration: InputDecoration.collapsed(
              hintText: 'Sizes e.g. Small/Regular/Large',
              border: UnderlineInputBorder()),
          maxLines: 1,
          autocorrect: false,
          validator: (val) => null,
          onSaved: (val) => variant = val.trim(),
        ),
      ),
      Utils.padded(
          child: TextFormField(
              key: Key('price'),
              initialValue: price,
              //keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: "Price(s)... separate each by '/' ",
                  border: UnderlineInputBorder()),
              autocorrect: false,
              validator: (val) {
                _validatePrices(val);
              },
              onSaved: (val) => price = val.trim())),
      picChosen == false
          ? _galleryOrCameraButtonBar(onPhotoSelected, onPhotoTaken)
          : _picChosenAffirmation(),
      submitButton
    ];
  }

  /// displays just name, variant and price to affirm the menu item has been saved
  List<Widget> formFieldsAffirmSave(Widget submitButton) {
    return [
      Utils.padded(
        child: TextFormField(
          key: Key('name'),
          initialValue: name,
          enabled: false,
          decoration: InputDecoration(labelText: 'Name'),
          validator: (val) => val.isEmpty ? 'Name can\'t be empty.' : null,
          onSaved: (val) => name = val.trim(),
        ),
      ),
      cloudUrl == null || cloudUrl.isEmpty
          ? Text('No image was provided', style: AppThemeText.warn14)
          : Image.network(
              cloudUrl,
              fit: BoxFit.contain,
            ),
      submitButton
    ];
  }
}
