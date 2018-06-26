import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:offerz/model/establishment.dart';
import 'package:offerz/model/menulist.dart';
import 'package:offerz/ui/theme.dart';

class RegularMenuListWidget extends StatefulWidget {
  final Firestore firestore;
  final Establishment establishment;
  final VoidCallback onNewItemWanted;

  RegularMenuListWidget(
      this.firestore, this.establishment, this.onNewItemWanted);

  @override
  _RegularMenuState createState() => _RegularMenuState();
}

class _RegularMenuState extends State<RegularMenuListWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment(1.0, 1.0),
        children: <Widget>[
          MenuList(widget.establishment),
          Container(
            color: AppThemeColors.textBackground,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('Add item', style: AppThemeText.norm14),
                  FloatingActionButton(
                      child: Icon(Icons.add,
                          color: AppThemeColors.main[50], size: 30.0),
                      onPressed: () => widget.onNewItemWanted())
                ]),
          )
        ],
      ),
    );
  }
}
