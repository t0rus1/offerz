import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:offerz/model/establishment_model.dart';
import 'package:offerz/special_typedefs.dart';
import 'package:offerz/widgets/regularmenu_stream_widget.dart';
import 'package:offerz/ui/theme.dart';

class RegularMenuWidget extends StatefulWidget {
  final Firestore firestore;
  final EstablishmentModel establishment;
  final VoidCallback onNewItemWanted;
  final NullFutureCallbackWithString onEditItemWanted;
  final NullFutureCallbackWithString onDeleteItemWanted;

  RegularMenuWidget(this.firestore, this.establishment, this.onNewItemWanted,
      this.onEditItemWanted, this.onDeleteItemWanted);

  @override
  _RegularMenuState createState() => _RegularMenuState();
}

class _RegularMenuState extends State<RegularMenuWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment(0.90, 0.98),
        children: <Widget>[
          RegularMenuStreamWidget(widget.establishment, widget.onEditItemWanted,
              widget.onDeleteItemWanted),
          Container(
            //color: AppThemeColors.textBackgroundMoreOpaque,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Text('Add an item to the menu', style: AppThemeText.norm14),
                  FloatingActionButton(
                      child: Icon(Icons.add,
                          color: AppThemeColors.main[50], size: 30.0),
                      tooltip: 'add an item to the menu',
                      onPressed: () => widget.onNewItemWanted())
                ]),
          )
        ],
      ),
    );
  }
}
