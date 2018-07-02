import 'package:flutter/material.dart';
import 'package:offerz/globals.dart' as globals;
import 'package:offerz/model/establishment_model.dart';
import 'package:offerz/ui/theme.dart';

class EstablishmentMapWidget extends StatefulWidget {
  EstablishmentMapWidget(this.outlet);

  final EstablishmentModel outlet;

  @override
  State<StatefulWidget> createState() => new _EstablishmentMapWidgetState();
}

class _EstablishmentMapWidgetState extends State<EstablishmentMapWidget> {
  var mapZoom = 14;
  var mapType = 'roadmap';
  var mapWidth = 600.0;
  var mapHeight = 900.0;
  var mapSize = '600x900';

  String googleStaticMapUrl() {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=${widget.outlet.latitude},${widget.outlet.longitude}&zoom=$mapZoom&size=$mapSize&maptype=$mapType' +
        '&markers=color:red|label:X|${widget.outlet.latitude},${widget.outlet.longitude}' +
        '&key=${globals.MAPS_STATIC_API_KEY}';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment(0.0, 0.95), children: <Widget>[
      Container(
          child: Image.network(
        googleStaticMapUrl(),
        width: mapWidth,
        height: mapHeight,
        fit: BoxFit.cover,
      )),
      Container(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          FloatingActionButton(
              tooltip: 'push an offer to patrons in the area',
              child: Icon(Icons.add_alert,
                  color: AppThemeColors.main[50], size: 30.0),
              onPressed: () {}),
        ]),
      ),
    ]);
  }
}
