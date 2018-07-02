import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:offerz/helpers/geolocator.dart';

import 'package:offerz/model/establishment_model.dart';
import 'package:offerz/special_typedefs.dart';
import 'package:offerz/globals.dart' as globals;
import 'package:offerz/ui/theme.dart';

class EstablishmentLocationWidget extends StatefulWidget {
  EstablishmentLocationWidget(this.estabInfo, this.onOutletLocationConfirmed);

  final EstablishmentModel estabInfo;
  final WithEstablishmentFunction onOutletLocationConfirmed;

  @override
  _OutletLocationWidgetState createState() => _OutletLocationWidgetState();
}

class _OutletLocationWidgetState extends State<EstablishmentLocationWidget> {
  Geolocater locationProvider = Geolocater();
  String placeUrl;
  String mapUrl;
  var locationDetails;
  var locationComponents;
  var locationAnnotations;
  var w3wReverseInfo;
  String w3wMapUrl;
  String _locationMessage = "Acquiring location...";
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
  // see https://opencagedata.com/api#reverse-resp
  Future<void> getAddressFromLocation() async {
    var requestUrl =
        'https://api.opencagedata.com/geocode/v1/json?q=${locationProvider.latitude}+${locationProvider.longitude}&key=${globals.OPEN_CAGE_API_KEY}';
    var response = await http.get(requestUrl);
    locationDetails = jsonDecode(response.body);

    locationComponents = locationDetails['results'][0]['components'];
    // print('locationComponents');
    // print(JsonEncoder.withIndent("  ").convert(locationComponents));
    // print('\n');

    locationAnnotations = locationDetails['results'][0]['annotations'];
    // print('locationAnnotations');
    // print(JsonEncoder.withIndent("  ").convert(locationAnnotations));
    // print('\n');
  }

  void warningAcknowledged() {
    setState(() {
      warningShown = true;
    });
  }

  String updateEstablishment() {
    widget.estabInfo.address =
        '${locationComponents['road']},${locationComponents['suburb']},${locationComponents['town']}, ${locationComponents['state']}';

    // opencage does not have 'city', so use 'county' instead ??
    widget.estabInfo.city = locationComponents['county'];
    widget.estabInfo.town = locationComponents['town'];
    widget.estabInfo.country = locationComponents['country'];

    widget.estabInfo.currency = locationAnnotations['currency']['symbol'];
    widget.estabInfo.what3words = locationAnnotations['what3words']['words'];

    return widget.estabInfo.address;
  }

  @override
  void initState() {
    super.initState();
    locationProvider.lastKnown().then((locationResult) {
      if (locationResult.isSuccessful) {
        getAddressFromLocation().whenComplete(() {
          if (locationDetails['total_results'] > 0) {
            setState(() {
              _locationMessage = updateEstablishment();
            });
          }
        });
      } else {
        print('location result not successfull');
      }
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
        warningShown
            ? Container(
                alignment: Alignment(-0.95, 1.0),
                child: Text(
                  _locationMessage,
                  style: AppThemeText.norm10,
                ))
            : Container(
                padding: EdgeInsets.all(10.0),
                color: AppThemeColors.textBackgroundMoreOpaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(globals.locationSetWarning),
                    FlatButton(
                      color: AppThemeColors.main[900],
                      child: Text(
                        'OK',
                        style: AppThemeText.btn20,
                      ),
                      onPressed: warningAcknowledged,
                    ),
                  ],
                ),
              ),
        warningShown
            ? Container(
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
              )
            : Text('please note the above!'),
      ],
    ));
  }
}
