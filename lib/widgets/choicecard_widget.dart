import 'package:flutter/material.dart';

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice, this.cardContent}) : super(key: key);
  final Choice choice;
  final Widget cardContent;

  Widget get placeholderCardChild {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(choice.icon, size: 128.0, color: Colors.black54),
          Text(choice.title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      color: Colors.white,
      child: cardContent ?? placeholderCardChild,
    );
  }
}
