import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:offerz/globals.dart' as globals;
import 'package:offerz/special_typedefs.dart';
import 'package:offerz/ui/theme.dart';
import 'package:offerz/interface/basegeolocation.dart';
import 'package:offerz/model/establishment.dart';

class OutletLocationPage extends StatefulWidget {
  OutletLocationPage(
      this.locationProvider, this.estabInfo, this.onOutletLocationConfirmed);

  final BaseGeolocation locationProvider;
  final Establishment estabInfo;
  final WithEstablishmentFunction onOutletLocationConfirmed;

  @override
  State<StatefulWidget> createState() => new _OutletLocationPageState();
}

class _OutletLocationPageState extends State<OutletLocationPage> {
  String placeUrl;
  String mapUrl;
  var locationDetails;
  //var mapDetails;
  var w3wReverseInfo;
  String w3wMapUrl;

  String placeInfo = 'please wait...';
  var mapInfo;

  var mapZoom = 18;
  var mapSize = '600x900';
  var mapType = 'roadmap';

  String googleStaticMapUrl() {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=${widget.locationProvider.latitude},${widget.locationProvider.longitude}&zoom=$mapZoom&size=$mapSize&maptype=$mapType' +
        '&markers=color:red|label:X|${widget.locationProvider.latitude},${widget.locationProvider.longitude}' +
        '&key=${globals.MAPS_STATIC_API_KEY}';
  }

  // obtain a plain 'address' from opencage by providing lat and long
  Future<void> getAddressFromLocation() async {
    var requestUrl =
        'https://api.opencagedata.com/geocode/v1/json?q=${widget.locationProvider.latitude}+${widget.locationProvider.longitude}&key=${globals.OPEN_CAGE_API_KEY}';
    var response = await http.get(requestUrl);
    locationDetails = jsonDecode(response.body);
  }

  // obtain what3words address of the users current location
  // Future<void> get3wordAddress() async {
  //   var resourceUrl = 'https://api.what3words.com/v2/reverse';
  //   var query =
  //       '?coords=${widget.locationProvider.latitude},${widget.locationProvider.longitude}&key=${globals.WHAT3_WORDS_API_KEY}&lang=en&format=json&display=full';
  //   var requestUrl = resourceUrl + query;

  //   var response = await http.get(requestUrl);

  //   // decode the reponse into a Map
  //   w3wReverseInfo = jsonDecode(response.body);
  //   w3wMapUrl = w3wReverseInfo['map'];
  //   w3wMapUrl = w3wMapUrl.replaceAll(RegExp('http'), 'https');
  // }

  @override
  void initState() {
    super.initState();
    getAddressFromLocation().whenComplete(() {
      if (locationDetails['total_results'] > 0) {
        setState(() {
          placeInfo = '${locationDetails['results'][0]['formatted']}';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Outlet\'s location',
              style: TextStyle(
                color: AppThemeColors.main[50],
                fontSize: 18.0,
              )),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Confirm ${widget.estabInfo.name}\'s location',
          child: Icon(Icons.done),
          onPressed: () {
            widget.estabInfo.latitude = widget.locationProvider.latitude;
            widget.estabInfo.longitude = widget.locationProvider.longitude;
            widget.onOutletLocationConfirmed(widget.estabInfo);
          },
        ),
        body: Stack(
          children: <Widget>[
            Container(
                child: Image.network(
              googleStaticMapUrl(),
              width: 600.0,
              height: 900.0,
              fit: BoxFit.cover,
            )),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration:
                  BoxDecoration(color: Color.fromARGB(50, 71, 150, 236)),
              child: Text(placeInfo,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
            ),
            Positioned(
              bottom: 60.0,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration:
                    BoxDecoration(color: Color.fromARGB(50, 71, 150, 236)),
                child: Text(
                  'Confirm you\'re at ${widget.estabInfo.name}\'s location',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
