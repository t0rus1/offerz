import 'dart:async';
import 'package:geolocation/geolocation.dart';
import 'package:offerz/model/establishment_model.dart';

typedef Future<void> WithEstablishmentFunction(EstablishmentModel estabmnt);
typedef void WithLocationResult(LocationResult result);
typedef Future<Null> NullFutureCallback();
typedef Future<void> NullFutureCallbackWithString(String param);
