import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:offerz/model/establishment_model.dart';
import 'package:offerz/special_typedefs.dart';
import 'package:offerz/ui/theme.dart';

Stack imageWithCodeAndDeleteOverlay(String docID, String itemCode, Image img,
    NullFutureCallbackWithString onDeleteMenuItemWanted) {
  return Stack(alignment: Alignment(-0.9, 0.95), children: <Widget>[
    Container(alignment: Alignment(0.0, 0.0), child: img),
    Container(
      //width: 40.0,
      child: Text(
        itemCode,
        style: AppThemeText.norm14,
      ),
      color: AppThemeColors.main[100],
    ),
    Container(
      alignment: Alignment(0.95, 0.0),
      child: IconButton(
        icon: Icon(
          Icons.delete_forever,
          color: AppThemeColors.main[800],
          size: 35.0,
        ),
        onPressed: () => onDeleteMenuItemWanted(docID),
      ),
    )
  ]);
}

Widget composeItemImage(DocumentSnapshot document,
    NullFutureCallbackWithString onDeleteMenuItemWanted) {
  String cacheName = document.data['cacheName'] ?? '';
  print('cacheName=$cacheName');
  //can we serve up cached version?
  if (cacheName.isNotEmpty) {
    //final Directory tempDir = Directory.systemTemp;
    //File file = File('${tempDir.path}/$cacheName');
    File file = File(cacheName);
    if (file.existsSync()) {
      print('serving up cached image');
      return imageWithCodeAndDeleteOverlay(
          document.documentID,
          document.data['code'] ?? '',
          Image.asset(file.path, fit: BoxFit.scaleDown),
          onDeleteMenuItemWanted);
    }
  }

  //else serve up remote version
  String cloudUrl = document.data['cloudUrl'] ?? '';
  print('cloudUrl=$cloudUrl');
  if (cloudUrl.isNotEmpty) {
    print('serving up remote image');
    return imageWithCodeAndDeleteOverlay(
        document.documentID,
        document.data['code'] ?? '',
        Image.network(cloudUrl, fit: BoxFit.scaleDown),
        onDeleteMenuItemWanted);
  }

  //no image at all
  return Text(
    'no image yet ...',
    style: AppThemeText.light14,
  );
}

Widget priceWidget(String currencySymbol, String priceString) {
  var prices = priceString.split("/");
  var priceBreaks = '$currencySymbol ' + prices.join('\n$currencySymbol ');

  return Text(
    priceBreaks,
    style: AppThemeText.itemPrice14,
  );
}

Widget regularMenuStreamTile(
    EstablishmentModel estab,
    DocumentSnapshot document,
    NullFutureCallbackWithString onEditMenuItemWanted,
    NullFutureCallbackWithString onDeleteMenuItemWanted) {
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
            trailing: priceWidget(estab.currency, document['price']),
            onTap: () {
              onEditMenuItemWanted(document.documentID);
            },
          ),
          Text(
            document['description'] ?? 'no item description yet ...',
            style: AppThemeText.light14,
            softWrap: true,
          ),
          composeItemImage(document, onDeleteMenuItemWanted)
        ],
      ));
}
