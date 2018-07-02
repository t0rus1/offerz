import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/ui/theme.dart';

import 'package:offerz/model/establishment_model.dart';
import 'package:offerz/model/regularmenuitem_model.dart';

import 'package:offerz/widgets/establishment_map_widget.dart';
import 'package:offerz/widgets/choicecard_widget.dart';
import 'package:offerz/widgets/establishment_location_widget.dart';
import 'package:offerz/widgets/regularmenu_widget.dart';

import 'package:offerz/forms/regularmenuitem_form.dart';
import 'package:offerz/forms/establishment_settings_form.dart';

class EstablishmentHomePage extends StatefulWidget {
  EstablishmentHomePage(this.firestore, this.establishment);

  final Firestore firestore;
  final EstablishmentModel establishment;

  @override
  State<StatefulWidget> createState() => new _OutletHomePageState();
}

class _OutletHomePageState extends State<EstablishmentHomePage> {
  Choice _selectedChoice = choices[0];

  RegularMenuItemModel _regularMenuItem;
  String _targetItemID;

  static const List<Choice> choices = const <Choice>[
    const Choice(title: 'Home', icon: Icons.home),
    const Choice(title: 'Regular Menu', icon: Icons.description),
    const Choice(title: 'Set Location', icon: Icons.location_on),
    const Choice(title: 'Other Settings', icon: Icons.settings),
  ];

  Widget get _cardContent {
    switch (_selectedChoice.title) {
      case 'Home':
        return EstablishmentMapWidget(widget.establishment);
      case 'Regular Menu': // shows establishment menu
        return RegularMenuWidget(
            widget.firestore,
            widget.establishment,
            _onNewRegularMenuItemWanted,
            _onEditRegularMenuItemWanted,
            _onDeleteRegularMenuItemWanted);
      case 'Set Location': // allows owner to locate his outlet
        return EstablishmentLocationWidget(
            widget.establishment, _onOutletLocationConfirmed);
      case 'Other Settings': // form to manage outlet name, description etc
        return EstablishmentSettingsForm(
            widget.firestore, widget.establishment, outletProfileUpdated);

      // this option does not appear in the menu but is rather invoked by
      //the action of the user wanting to add a new regularMenuItem when
      //when viewing the 'Regular Menu' (see above)
      case '__newRegularMenuItemWanted': // form for a new menu item
        _regularMenuItem =
            RegularMenuItemModel('new', new Map<String, dynamic>());
        return RegularMenuItemForm(widget.firestore, widget.establishment,
            _regularMenuItem, _onRegularMenuItemCompleted, false);

      // this option does not appear in the menu but is rather invoked by
      //the action of the user wanting to edit an existing regularMenuItem when
      //when viewing the 'Regular Menu' (see above)
      case '__editRegularMenuItemWanted': // form to edit an existing menu item
        //instantiate an empty regularmenu (except for documentID field) item
        //the form will detect that an 'edit' is required
        return RegularMenuItemForm(widget.firestore, widget.establishment,
            _regularMenuItem, _onRegularMenuItemCompleted, true);

      default:
        return null;
    }
  }

  //sets lat and long in establishment record in firestore
  Future<void> _onOutletLocationConfirmed(EstablishmentModel estab) async {
    print('outletLocationConfirmed');
    var estabDoc = widget.firestore
        .collection('establishments')
        .document(estab.documentID);

    estabDoc.setData(estab.localizationMap, merge: true).whenComplete(() {
      print('updated localization in ${estab.name} record');
      outletProfileUpdated();
    }).catchError((e) => print(e));
  }

  //user wants to create a new menu item
  _onNewRegularMenuItemWanted() {
    print('_onNewRegularMenuItemWanted');
    setState(() {
      //construct a 'fake' choice to get new card showing form fields for a new menu item
      _selectedChoice = Choice(title: '__newRegularMenuItemWanted');
    });
  }

  //load and return a menu item for editing / deleting
  Future<RegularMenuItemModel> loadMenuItem(String itemID) async {
    var estabDoc = widget.firestore
        .collection('establishments')
        .document(widget.establishment.documentID);

    var menuItemDoc = estabDoc.collection('menu').document(itemID);

    var menuShot = await menuItemDoc.get();
    print('loadMenuItem ${menuShot.documentID} name: ${menuShot.data['name']}');
    return RegularMenuItemModel(menuShot.documentID, menuShot.data);
  }

  DocumentReference getMenuItemDoc(String itemID) {
    var estabDoc = widget.firestore
        .collection('establishments')
        .document(widget.establishment.documentID);

    return estabDoc.collection('menu').document(itemID);
  }

  //user wants to edit an existing menu item
  Future<Null> _onEditRegularMenuItemWanted(String targetItemID) async {
    print('_onEditRegularMenuItemWanted for item $targetItemID');
    loadMenuItem(targetItemID).then((loadedItem) {
      setState(() {
        //construct a 'fake' choice to get a card showing form fields to edit menu item
        _regularMenuItem = loadedItem;
        _targetItemID = targetItemID;
        _selectedChoice = Choice(title: '__editRegularMenuItemWanted');
      });
    });
  }

  Future<Null> _confirmDeletion(RegularMenuItemModel item) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Confirm deletion'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('Delete ${item.name}?'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('YES'),
              onPressed: () {
                //we need a doc reference in order to delete
                var menuItemDoc = getMenuItemDoc(item.documentID);
                menuItemDoc.delete();
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Null> _onDeleteRegularMenuItemWanted(String targetItemID) async {
    print('_onDeleteRegularMenuItemWanted for item $targetItemID');
    loadMenuItem(targetItemID).then((loadedItem) {
      _confirmDeletion(loadedItem).whenComplete(() {
        // setState(() {
        // });
      });
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

  PopupMenuButton<Choice> buildPopupMenu() {
    return PopupMenuButton<Choice>(
      onSelected: _select,
      itemBuilder: (BuildContext context) {
        return choices.skip(2).map((Choice choice) {
          return PopupMenuItem<Choice>(
              value: choice, child: Text(choice.title));
        }).toList();
      },
    );
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
            tooltip: 'Share an offer',
          ),
          IconButton(
            icon: Icon(choices[1].icon),
            //iconSize: 32.0,
            color: AppThemeColors.main[50],
            onPressed: () => _select(choices[1]),
            tooltip: 'manage the menu',
          ),
          // overflow menu
          buildPopupMenu()
        ],
      ),
      backgroundColor: AppThemeColors.main[400],
      body: Padding(
        padding: const EdgeInsets.only(),
        child: ChoiceCard(choice: _selectedChoice, cardContent: _cardContent),
      ),
    );
  }
}
