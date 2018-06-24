import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:offerz/helpers/geolocator.dart';
import 'package:offerz/helpers/utils.dart';

import 'package:offerz/model/establishment.dart';
import 'package:offerz/special_typedefs.dart';
import 'package:offerz/globals.dart' as globals;
import 'package:offerz/ui/theme.dart';

class OutletLocationWidget extends StatefulWidget {
  OutletLocationWidget(this.estabInfo, this.onOutletLocationConfirmed);

  final Establishment estabInfo;
  final WithEstablishmentFunction onOutletLocationConfirmed;

  @override
  _OutletLocationWidgetState createState() => _OutletLocationWidgetState();
}

class _OutletLocationWidgetState extends State<OutletLocationWidget> {
  Geolocater locationProvider = Geolocater();
  String placeUrl;
  String mapUrl;
  var locationDetails;
  var locationComponents;
  var w3wReverseInfo;
  String w3wMapUrl;
  String waitForLocation = "Acquiring location...";
  bool warningShown = false;
  var mapInfo;

  var mapZoom = 18;
  var mapSize = '600x900';
  var mapType = 'roadmap';

  String googleStaticMapUrl() {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=${locationProvider.latitude},${locationProvider.longitude}&zoom=$mapZoom&size=$mapSize&maptype=$mapType' +
        '&markers=color:red|label:X|${locationProvider.latitude},${locationProvider.longitude}' +
        '&key=${globals.MAPS_STATIC_API_KEY}';
  }

  // obtain a plain 'address' from opencage by providing lat and long
  Future<void> getAddressFromLocation() async {
    var requestUrl =
        'https://api.opencagedata.com/geocode/v1/json?q=${locationProvider.latitude}+${locationProvider.longitude}&key=${globals.OPEN_CAGE_API_KEY}';
    var response = await http.get(requestUrl);
    locationDetails = jsonDecode(response.body);
    locationComponents = locationDetails['results'][0]['components'];
  }

  Future<Null> _locationWarning() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Please note'),
          content: new SingleChildScrollView(
              child: Text(globals.locationSetWarning)),
          actions: <Widget>[
            new FlatButton(
              child: new Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _locationWarning().whenComplete(() {
      locationProvider.isOperational().then((operational) {
        if (operational) {
          locationProvider.lastKnown().then((locationResult) {
            if (locationResult.isSuccessful) {
              getAddressFromLocation().whenComplete(() {
                if (locationDetails['total_results'] > 0) {
                  setState(() {
                    widget.estabInfo.address =
                        '${locationComponents['road']},${locationComponents['town']},${locationComponents['state']}';
                    waitForLocation = widget.estabInfo.address;
                  });
                }
              });
            } else {
              print('location result not successfull');
            }
          });
        } else {
          print('location service not operational');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      alignment: Alignment(1.0, 1.0),
      children: <Widget>[
        Container(
            child: Image.network(
          googleStaticMapUrl(),
          width: 600.0,
          height: 900.0,
          fit: BoxFit.cover,
        )),
        Container(
            alignment: Alignment(-0.95, 1.0),
            child: Text(
              waitForLocation,
              style: TextStyle(color: AppThemeColors.main[900]),
            )),
        Container(
          color: AppThemeColors.textBackground,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                'Set as ${widget.estabInfo.name}\'s location',
                style: AppThemeText.norm14,
              ),
              FloatingActionButton(
                  tooltip: "confirm you're here at this outlet",
                  child: Icon(Icons.done,
                      color: AppThemeColors.main[50], size: 30.0),
                  onPressed: () {
                    widget.onOutletLocationConfirmed(widget.estabInfo);
                  }),
            ],
          ),
        ),
      ],
    ));
  }
}
