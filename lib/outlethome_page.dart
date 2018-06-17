import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:offerz/ui/theme.dart';
import 'package:offerz/model/establishment.dart';
import 'package:offerz/widgets/establishmentmap_widget.dart';
import 'package:offerz/widgets/choicecard_widget.dart';
import 'package:offerz/widgets/establishmentsettings_widget.dart';

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Home', icon: Icons.location_on),
  const Choice(title: 'Compose an Offer', icon: Icons.announcement),
  const Choice(title: 'Option 3', icon: Icons.filter_3),
  const Choice(title: 'Option 4', icon: Icons.filter_4),
  const Choice(title: 'Option 5', icon: Icons.filter_5),
  const Choice(title: 'Option 6', icon: Icons.filter_6),
  const Choice(title: 'Outlet Profile', icon: Icons.settings),
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

  Widget get _cardContent {
    switch (_selectedChoice.title) {
      case 'Home':
        return EstablishmentMapWidget(widget.establishment);
      case 'Outlet Profile':
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
