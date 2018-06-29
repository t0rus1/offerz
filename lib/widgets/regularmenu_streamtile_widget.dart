import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:offerz/special_typedefs.dart';
import 'package:offerz/ui/theme.dart';

Stack imageWithItemCode(String docID, String itemCode, Image img) {
  return Stack(children: <Widget>[
    img,
    Container(
      child: Text(
        itemCode,
        style: AppThemeText.norm14,
      ),
      color: AppThemeColors.main[100],
    )
  ]);
}

Widget cachedOrCloudImage(DocumentSnapshot document) {
  final String cacheName = document['cacheName'] ?? '';

  //can we serve up cached version?
  if (cacheName.isNotEmpty) {
    final Directory tempDir = Directory.systemTemp;
    File file = File('${tempDir.path}/$cacheName');
    if (file.existsSync()) {
      print('serving up cached image');
      return imageWithItemCode(document.documentID, document.data['code'] ?? '',
          Image.asset(file.path, fit: BoxFit.scaleDown));
    }
  }

  //else serve up remote version
  String cloudUrl = document['cloudUrl'] ?? '';
  if (cloudUrl.isNotEmpty) {
    print('serving up remote image');
    return imageWithItemCode(document.documentID, document.data['code'] ?? '',
        Image.network(cloudUrl, fit: BoxFit.scaleDown));
  }

  //no image at all
  return Text(
    'no image yet ...',
    style: AppThemeText.light14,
  );
}

Widget priceWidget(String priceString) {
  var prices = priceString.split("/");
  var priceBreaks = prices.join("\n");

  return Text(
    priceBreaks,
    style: AppThemeText.itemPrice14,
  );
}

Widget regularMenuStreamTile(DocumentSnapshot document,
    NullFutureCallbackWithString onEditMenuItemWanted) {
  return Container(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            color: AppThemeColors.main[100],
            height: 2.0,
          ),
          ListTile(
            leading: CircleAvatar(
              child: Icon(
                Icons.edit,
                color: AppThemeColors.main[800],
              ),
              radius: 20.0,
            ),
            title: Text(document['name']),
            subtitle: Text(document['variant']),
            trailing: priceWidget(document['price']),
            onTap: () {
              onEditMenuItemWanted(document.documentID);
            },
          ),
          Text(
            document['description'] ?? 'no item description yet ...',
            style: AppThemeText.light14,
            softWrap: true,
          ),
          cachedOrCloudImage(document)
        ],
      ));
}
