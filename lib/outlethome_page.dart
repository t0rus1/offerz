import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:offerz/ui/theme.dart';

class OutletHomePage extends StatefulWidget {
  OutletHomePage(this.establishment);

  final DocumentSnapshot establishment;

  @override
  State<StatefulWidget> createState() => new _OutletHomePageState();
}

class _OutletHomePageState extends State<OutletHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.establishment.data['name']),
        actions: <Widget>[],
      ),
      backgroundColor: AppThemeColors.main[400],
      body: Center(child: Text("this is where the action will be")),
    );
  }
}
