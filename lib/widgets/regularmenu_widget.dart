import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:offerz/model/establishment.dart';
import 'package:offerz/ui/theme.dart';

class RegularMenuWidget extends StatefulWidget {
  final Firestore firestore;
  final Establishment establishment;
  final VoidCallback onNewItemWanted;

  RegularMenuWidget(this.firestore, this.establishment, this.onNewItemWanted);

  @override
  _RegularMenuState createState() => _RegularMenuState();
}

class _RegularMenuState extends State<RegularMenuWidget> {
  ListTile _getmenuItem(int index) {
    return ListTile(
      leading: Icon(Icons.fastfood),
      enabled: true,
      title: Text("item ${index+1}"),
      subtitle: Text('description of item...'),
    );
  }

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
          ListView.builder(
              padding: EdgeInsets.all(5.0),
              itemExtent: 50.0,
              itemBuilder: (BuildContext context, int index) {
                return _getmenuItem(index);
              }),
          Container(
            color: AppThemeColors.textBackground,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('Add a regular menu item', style: AppThemeText.norm14),
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
