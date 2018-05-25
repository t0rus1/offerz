import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_picker/location_picker.dart';

import 'package:offerz/globals.dart' as globals;

class SetLocationPage extends StatefulWidget {

  @override
  _SetLocationPageState createState() => new _SetLocationPageState();
}

class _SetLocationPageState extends State<SetLocationPage> {

  String _platformVersion = 'Unknown';
  String _locationPickerData = 'locationPicker';

  Map<dynamic, dynamic> result = new Map();
  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    LocationPicker.initApiKey(globals.MAPS_STATIC_API_KEY);
    LocationPicker picker = new LocationPicker();
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await picker.showLocationPicker;
    } on PlatformException {
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
    _locationPickerData = result.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Set your location'),
        ),
        body: new Center(
          child: new Text(_locationPickerData),
        ),
      ),
    );
  }
}