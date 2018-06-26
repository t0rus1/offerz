import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:offerz/model/establishment.dart';
import 'package:offerz/ui/theme.dart';

/// a list widget which subscribes to firestore stream
class MenuList extends StatelessWidget {
  final Establishment establishment;
  MenuList(this.establishment);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('establishments')
          .document(establishment.documentID)
          .collection('menu')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Text('Loading...');
        return ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document) {
            return listMenuTile(document);
          }).toList(),
        );
      },
    );
  }
}

Widget listMenuTile(DocumentSnapshot document) {
  return Container(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      ListTile(
          leading: Icon(
            Icons.arrow_downward,
            size: 30.0,
          ),
          title: Text(document['name']),
          subtitle: Text(document['variant']),
          trailing: Text(document['price'].toString(),
              style: AppThemeText.itemPrice20)),
      Text(
        document['description'],
        style: AppThemeText.light14,
      ),
      Image.network(
        document['storageImageUrl'] ?? '',
        fit: BoxFit.scaleDown,
      ),
    ],
  ));
}
