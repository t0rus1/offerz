import 'package:flutter/material.dart';
import 'package:offerz/globals.dart' as globals;
import 'package:offerz/model/establishment.dart';

class EstablishmentMapWidget extends StatefulWidget {
  EstablishmentMapWidget(this.outlet);

  final Establishment outlet;

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
    return Container(
        child: Stack(
      children: <Widget>[
        Container(
            child: Image.network(
          googleStaticMapUrl(),
          width: mapWidth,
          height: mapHeight,
          fit: BoxFit.cover,
        )),
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(color: Color.fromARGB(50, 71, 150, 236)),
          child: Text('${widget.outlet.address}\n${widget.outlet.description}',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
        ),
        Positioned(
          bottom: 20.0,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromARGB(50, 71, 150, 236)),
            child: Text(
              'Offers will be pushed to your patrons\nin this vicinity',
              style: TextStyle(
                fontSize: 12.0,
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
