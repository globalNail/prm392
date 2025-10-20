import 'package:geocoding/geocoding.dart';
import '../../common/result.dart';
import '../../common/app_logger.dart';

/// Repository for geocoding operations
class GeocodeRepository {
  static final _logger = AppLogger('GeocodeRepository');

  /// Forward geocode an address to get latitude and longitude
  Future<Result<(double lat, double lng)>> geocodeAddress(
    String address,
  ) async {
    try {
      if (address.trim().isEmpty) {
        return const Failure('Địa chỉ không được để trống');
      }

      final locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        return const Failure('Không tìm thấy tọa độ cho địa chỉ này');
      }

      final location = locations.first;
      _logger.info(
        'Geocoded address: $address -> (${location.latitude}, ${location.longitude})',
      );

      return Success((location.latitude, location.longitude));
    } catch (e, stackTrace) {
      _logger.error('Error geocoding address: $address', e, stackTrace);
      return Failure(
        'Không thể tìm tọa độ cho địa chỉ này',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Reverse geocode coordinates to get address
  Future<Result<String>> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return const Failure('Không tìm thấy địa chỉ cho tọa độ này');
      }

      final placemark = placemarks.first;
      final address = [
        placemark.street,
        placemark.subLocality,
        placemark.locality,
        placemark.administrativeArea,
        placemark.country,
      ].where((part) => part != null && part.isNotEmpty).join(', ');

      _logger.info('Reverse geocoded: ($latitude, $longitude) -> $address');
      return Success(address);
    } catch (e, stackTrace) {
      _logger.error(
        'Error reverse geocoding: ($latitude, $longitude)',
        e,
        stackTrace,
      );
      return Failure(
        'Không thể tìm địa chỉ cho tọa độ này',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
