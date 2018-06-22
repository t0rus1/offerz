import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:offerz/ui/theme.dart';
import 'package:offerz/model/establishment.dart';
import 'package:offerz/widgets/establishmentmap_widget.dart';
import 'package:offerz/widgets/choicecard_widget.dart';
import 'package:offerz/widgets/establishmentsettings_widget.dart';
import 'package:offerz/widgets/outletlocation_widget.dart';

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Home', icon: Icons.home),
  const Choice(title: 'Setup Regular Menu', icon: Icons.local_pizza),
  const Choice(
      title: 'Settings: Establishment Location', icon: Icons.location_on),
  const Choice(title: 'Settings: Other', icon: Icons.settings),
];

class OutletHomePage extends StatefulWidget {
  OutletHomePage(this.firestore, this.establishment);

  final Firestore firestore;
  final Establishment establishment;

  @override
  State<StatefulWidget> createState() => new _OutletHomePageState();
}

class _OutletHomePageState extends State<OutletHomePage> {
  Choice _selectedChoice = choices[0];

  //sets lat and long in establishment record in firestore
  Future<void> _onOutletLocationConfirmed(Establishment estab) async {
    print('outletLocationConfirmed');
    var estabDoc = widget.firestore
        .collection('establishments')
        .document(estab.documentID);

    estabDoc.setData(estab.coOrdsMap, merge: true).whenComplete(() {
      print('updated lat & long in ${estab.name} record');
      outletProfileUpdated();
    }).catchError((e) => print(e));
  }

  Widget get _cardContent {
    switch (_selectedChoice.title) {
      case 'Home':
        return EstablishmentMapWidget(widget.establishment);
      case 'Settings: Establishment Location':
        return OutletLocationWidget(
            widget.establishment, _onOutletLocationConfirmed);
      case 'Settings: Other':
        return EstablishmentSettingsWidget(
            widget.firestore, widget.establishment, outletProfileUpdated);
      default:
        return null;
    }
  }

  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });
  }

  //callback activated after settings saved
  void outletProfileUpdated() {
    setState(() {
      _selectedChoice = choices[0];
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.establishment.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(choices[0].icon),
            //iconSize: 32.0,
            color: AppThemeColors.main[50],
            onPressed: () => _select(choices[0]),
          ),
          IconButton(
            icon: Icon(choices[1].icon),
            //iconSize: 32.0,
            color: AppThemeColors.main[50],
            onPressed: () => _select(choices[1]),
          ),
          // overflow menu
          PopupMenuButton<Choice>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return choices.skip(2).map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice, child: Text(choice.title));
              }).toList();
            },
          )
        ],
      ),
      backgroundColor: AppThemeColors.main[400],
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: ChoiceCard(choice: _selectedChoice, cardContent: _cardContent),
      ),
    );
  }
}
