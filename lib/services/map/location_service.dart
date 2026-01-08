import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _locationPermissionKey = 'location_permission_granted';

  static Future<bool> hasStoredPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationPermissionKey) ?? false;
  }

  static Future<void> savePermissionStatus(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPermissionKey, granted);
  }

  static Future<PermissionStatus> checkPermission() async {
    final geoStatus = await Geolocator.checkPermission();
    // Convert geolocator LocationPermission to permission_handler PermissionStatus
    switch (geoStatus) {
      case LocationPermission.denied:
        return PermissionStatus.denied;
      case LocationPermission.deniedForever:
        return PermissionStatus.permanentlyDenied;
      case LocationPermission.unableToDetermine:
        return PermissionStatus.denied;
      case LocationPermission.whileInUse:
        return PermissionStatus.granted;
      case LocationPermission.always:
        return PermissionStatus.granted;
    }
  }

  static Future<PermissionStatus> requestPermission() async {
    // Use Geolocator's requestPermission on iOS instead of permission_handler
    // This ensures the native iOS permission dialog appears correctly
    final geoStatus = await Geolocator.requestPermission();

    // Convert geolocator LocationPermission to permission_handler PermissionStatus
    PermissionStatus status;
    switch (geoStatus) {
      case LocationPermission.denied:
        status = PermissionStatus.denied;
      case LocationPermission.deniedForever:
        status = PermissionStatus.permanentlyDenied;
      case LocationPermission.unableToDetermine:
        status = PermissionStatus.denied;
      case LocationPermission.whileInUse:
        status = PermissionStatus.granted;
      case LocationPermission.always:
        status = PermissionStatus.granted;
    }

    await savePermissionStatus(status.isGranted);
    return status;
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final permission = await checkPermission();
      if (!permission.isGranted) return null;

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Position?> getLastKnownPosition() async {
    try {
      final permission = await checkPermission();
      if (!permission.isGranted) return null;

      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  static Future<LocationStatus> getLocationStatus() async {
    final permission = await checkPermission();
    final serviceEnabled = await isLocationServiceEnabled();

    if (!serviceEnabled) {
      return LocationStatus.serviceDisabled;
    }

    if (permission.isDenied) {
      return LocationStatus.denied;
    }

    if (permission.isPermanentlyDenied) {
      return LocationStatus.permanentlyDenied;
    }

    if (permission.isGranted) {
      return LocationStatus.granted;
    }

    return LocationStatus.denied;
  }
}

/// Enum for location status
enum LocationStatus { granted, denied, permanentlyDenied, serviceDisabled }
