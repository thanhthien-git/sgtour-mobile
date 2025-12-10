import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle location permissions and fetching location
class LocationService {
  static const String _locationPermissionKey = 'location_permission_granted';

  /// Check if location permission was previously granted and saved
  static Future<bool> hasStoredPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationPermissionKey) ?? false;
  }

  /// Save permission status to local storage
  static Future<void> savePermissionStatus(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPermissionKey, granted);
  }

  /// Check current location permission status
  static Future<PermissionStatus> checkPermission() async {
    return await Permission.location.status;
  }

  /// Request location permission
  static Future<PermissionStatus> requestPermission() async {
    final status = await Permission.location.request();
    await savePermissionStatus(status.isGranted);
    return status;
  }

  /// Check if location service is enabled on device
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open app settings for manual permission grant
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Open device location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Get current position
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

  /// Get last known position (faster, may be stale)
  static Future<Position?> getLastKnownPosition() async {
    try {
      final permission = await checkPermission();
      if (!permission.isGranted) return null;

      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  /// Check all requirements for location access
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
