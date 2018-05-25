library offerz.utils;

import 'package:flutter/material.dart';

Widget padded({Widget child}) {
  return new Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: child,
  );
}

