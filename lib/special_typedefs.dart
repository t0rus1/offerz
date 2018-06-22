import 'dart:async';
import 'package:geolocation/geolocation.dart';
import 'package:offerz/model/establishment.dart';

typedef Future<void> WithEstablishmentFunction(Establishment estabmnt);
typedef void WithLocationResult(LocationResult result);
