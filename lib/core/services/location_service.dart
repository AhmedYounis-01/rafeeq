import 'package:rafeeq/core/helpers/app_logger.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String cityName;
  final String countryName;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.countryName,
  });
}

class LocationDeniedException implements Exception {
  final String message;
  const LocationDeniedException(this.message);
  @override
  String toString() => message;
}

class LocationPermanentlyDeniedException implements Exception {
  const LocationPermanentlyDeniedException();
  @override
  String toString() => 'تم رفض إذن الموقع نهائياً';
}

class LocationService {
  static Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  /// Gets the last known position or a default if not available.
  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  /// Requests permission and returns a [LocationResult] with coords + city info.
  static Future<LocationResult> requestAndGetLocation({
    bool forceRequest = false,
    bool useLastKnownIfAvailable = false,
  }) async {
    // 1. Check if the device location service is on
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationDeniedException('خدمة الموقع غير مفعّلة على جهازك');
    }

    // 2. Handle permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (forceRequest || permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationDeniedException('تم رفض إذن الوصول إلى الموقع');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermanentlyDeniedException();
    }

    Position? position;

    if (useLastKnownIfAvailable) {
      position = await getLastKnownPosition();
    }

    // 3. Get position if last known is null or not requested
    position ??= await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium, // Medium is usually faster than High
        timeLimit: Duration(seconds: 10),
      ),
    );

    // 4. Reverse geocode using geocoding package for better results
    final (city, country) = await _reverseGeocode(
      position.latitude,
      position.longitude,
    );

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: city,
      countryName: country,
    );
  }

  static Future<(String, String)> _reverseGeocode(
    double lat,
    double lon,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final city =
            p.locality ??
            p.subAdministrativeArea ??
            p.administrativeArea ??
            p.name ??
            'مجهول';
        final country = p.country ?? 'غير معروف';
        return (city, country);
      }
    } catch (e) {
      AppLogger.error('Geocoding Error', error: e, tag: 'LocationService');
    }
    // Fallback if geocoding fails
    return ((lat.toStringAsFixed(2)), (lon.toStringAsFixed(2)));
  }

  /// Opens app settings (for permissions)
  static Future<void> openAppSettings() => Geolocator.openAppSettings();

  /// Opens device location settings (for GPS toggle)
  static Future<void> openLocationSettings() =>
      Geolocator.openLocationSettings();
}
