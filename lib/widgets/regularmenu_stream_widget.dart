import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/model/establishment_model.dart';
import 'package:offerz/special_typedefs.dart';
import 'package:offerz/ui/theme.dart';
import 'package:offerz/widgets/regularmenu_streamtile_widget.dart';

/// a list widget which subscribes to firestore stream
class RegularMenuStreamWidget extends StatelessWidget {
  final EstablishmentModel establishment;
  final NullFutureCallbackWithString onEditMenuItemWanted;
  final NullFutureCallbackWithString onDeleteMenuItemWanted;
  RegularMenuStreamWidget(this.establishment, this.onEditMenuItemWanted,
      this.onDeleteMenuItemWanted);

  @override
  Widget build(BuildContext context) {
    var menuItemCollection = Firestore.instance
        .collection('establishments')
        .document(establishment.documentID)
        .collection('menu');

    return StreamBuilder<QuerySnapshot>(
      stream: menuItemCollection.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return ListView(children: <Widget>[
            ListTile(
              leading: Icon(Icons.info),
              title: Text(
                'No items found',
                style: AppThemeText.norm14,
              ),
            )
          ]);
        } else {
          return ListView(
            children: snapshot.data.documents.map((DocumentSnapshot document) {
              return regularMenuStreamTile(establishment, document,
                  onEditMenuItemWanted, onDeleteMenuItemWanted);
            }).toList(),
          );
        }
      },
    );
  }
}
