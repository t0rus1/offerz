import 'package:offerz/interface/basegeolocation.dart';
import 'package:geolocation/geolocation.dart';

// We implement a base geolocation interface using
// the flutter 'geolocation' package
// see https://pub.dartlang.org/packages/geolocation
class Geolocater implements BaseGeolocation {
  bool locationReady = false;
  double latitude;
  double longitude;

  handleLocationResult(LocationResult result) {
    if (result.isSuccessful) {
      // location request successful, location is guaranteed to not be null
      latitude = result.location.latitude;
      longitude = result.location.longitude;
      locationReady = true;
      print('latitiude: $latitude, longitude: $longitude');
    } else {
      switch (result.error.type) {
        case GeolocationResultErrorType.runtime:
          print('runtime error, ${result.error.message}');
          break;
        case GeolocationResultErrorType.locationNotFound:
          print('location request did not return any result');
          break;
        case GeolocationResultErrorType.serviceDisabled:
          print(
              'location services disabled on device - might be that GPS is turned off, or parental control (android)');
          break;
        case GeolocationResultErrorType.permissionDenied:
          print('user denied location permission request');
          // rejection is final on iOS, and can be on Android
          // user will need to manually allow the app from the settings
          break;
        case GeolocationResultErrorType.playServicesUnavailable:
          // android only
          // result.error.additionalInfo contains more details on the play services error
          switch (
              result.error.additionalInfo as GeolocationAndroidPlayServices) {
            // do something, like showing a dialog inviting the user to install/update play services
            case GeolocationAndroidPlayServices.missing:
              print('GeolocationAndroidPlayServices.missing');
              break;
            case GeolocationAndroidPlayServices.updating:
              print('GeolocationAndroidPlayServices.updating');
              break;
            case GeolocationAndroidPlayServices.versionUpdateRequired:
              print('GeolocationAndroidPlayServices.versionUpdateRequired');
              break;
            case GeolocationAndroidPlayServices.disabled:
              print('GeolocationAndroidPlayServices.disabled');
              break;
            case GeolocationAndroidPlayServices.invalid:
              print('GeolocationAndroidPlayServices.invalid');
              break;
          }
          break;
      }
    }
  }

  setDeviceLocation() {
    print('setDeviceLocation');
    Geolocation
        .currentLocation(accuracy: LocationAccuracy.best)
        .listen(handleLocationResult);
  }
}
