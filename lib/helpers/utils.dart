import 'package:flutter/material.dart';
import 'package:offerz/ui/theme.dart';

class Utils {
  static Widget logoAvatar(double radius) {
    return CircleAvatar(
      backgroundColor: AppThemeColors.main[900],
      radius: radius,
      child: Icon(
        Icons.loyalty,
        size: 5 * radius,
        color: AppThemeColors.main[50],
      ),
    );
  }

  static Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static Container waitingIndicator(String waitMessage) {
    var pr =
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Flexible(
        child: CircularProgressIndicator(
          value: null,
          backgroundColor: AppThemeColors.main[50],
          strokeWidth: 4.0,
        ),
      ),
      Flexible(
        child: Text(
          waitMessage,
          style: AppThemeText.norm12,
        ),
      ),
    ]);

    return Container(
      alignment: Alignment(0.0, 0.0),
      child: pr,
    );
  }
}
