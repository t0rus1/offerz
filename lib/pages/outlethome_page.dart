import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/ui/theme.dart';

import 'package:offerz/model/establishment.dart';
import 'package:offerz/model/regularmenuitem.dart';

import 'package:offerz/widgets/establishmentmap_widget.dart';
import 'package:offerz/widgets/choicecard_widget.dart';
import 'package:offerz/widgets/outletlocation_widget.dart';
import 'package:offerz/widgets/regularmenulist_widget.dart';

import 'package:offerz/forms/regularmenuitem_form.dart';
import 'package:offerz/forms/establishmentsettings_form.dart';

class OutletHomePage extends StatefulWidget {
  OutletHomePage(this.firestore, this.establishment);

  final Firestore firestore;
  final Establishment establishment;

  @override
  State<StatefulWidget> createState() => new _OutletHomePageState();
}

class _OutletHomePageState extends State<OutletHomePage> {
  Choice _selectedChoice = choices[0];

  RegularMenuItem _regularMenuItem;

  static const List<Choice> choices = const <Choice>[
    const Choice(title: 'Home', icon: Icons.home),
    const Choice(title: 'Regular Menu', icon: Icons.fastfood),
    const Choice(title: 'Set Location', icon: Icons.location_on),
    const Choice(title: 'Other Settings', icon: Icons.settings),
  ];

  Widget get _cardContent {
    switch (_selectedChoice.title) {
      case 'Home':
        return EstablishmentMapWidget(widget.establishment);
      case 'Regular Menu': // shows establishment menu
        return RegularMenuListWidget(widget.firestore, widget.establishment,
            _onNewRegularMenuItemWanted);
      case 'Set Location': // allows owner to locate his outlet
        return OutletLocationWidget(
            widget.establishment, _onOutletLocationConfirmed);
      case 'Other Settings': // form to manage outlet name, description etc
        return EstablishmentSettingsForm(
            widget.firestore, widget.establishment, outletProfileUpdated);

      // this option does not appear in the menu but is rather invoked by
      //the action of the user wanting to add a new regularMenuItem when
      //when viewing the 'Regular Menu' (see above)
      case '__newRegularMenuItemWanted': // form for a new menu item
        _regularMenuItem = RegularMenuItem('new', new Map<String, dynamic>());
        return RegularMenuItemForm(widget.firestore, widget.establishment,
            _regularMenuItem, _onRegularMenuItemCompleted);

      default:
        return null;
    }
  }

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

  _onNewRegularMenuItemWanted() {
    print('_onNewRegularMenuItemWanted');
    setState(() {
      //construct a 'fake' choice to get new card showing form fields for a new menu item
      _selectedChoice = Choice(title: '__newRegularMenuItemWanted');
    });
  }

  _onRegularMenuItemCompleted() {
    print('_onRegularMenuItemCompleted');
    setState(() {
      _selectedChoice = choices.firstWhere((c) => c.title == 'Regular Menu');
    });
  }

  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });
  }

  //callback activated after settings saved
  void outletProfileUpdated() {
    setState(() {
      _selectedChoice = choices.firstWhere((c) => c.title == 'Home');
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
