


import 'package:location/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:utils/utils.dart';


part 'location.g.dart';

@Riverpod(keepAlive: true)
Stream<LocationData?> location(LocationRef ref) async* {
  Location location = Location();
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  while(true) {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }
    if(permissionGranted == PermissionStatus.deniedForever) {
      yield null;
      break;
    }
    if (permissionGranted != PermissionStatus.granted || !serviceEnabled) {
      fluttertoastDefault("Brak możliwości ustalenia lokalizacji", true);
      yield null;
    }
    yield await location.getLocation();
    await Future.delayed(const Duration(seconds: 3));
  }
  yield null;
}