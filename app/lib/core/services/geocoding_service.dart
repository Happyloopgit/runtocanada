import 'package:dio/dio.dart';
import '../../../app/env.dart';

/// Model class for geocoding search results
class GeocodingResult {
  final String placeName;
  final String? address;
  final double latitude;
  final double longitude;
  final String? placeType;
  final String? country;
  final String? region;

  GeocodingResult({
    required this.placeName,
    this.address,
    required this.latitude,
    required this.longitude,
    this.placeType,
    this.country,
    this.region,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    final coordinates = json['geometry']['coordinates'] as List;
    final context = json['context'] as List<dynamic>?;

    String? country;
    String? region;

    if (context != null) {
      for (final item in context) {
        final id = item['id'] as String;
        if (id.startsWith('country')) {
          country = item['text'] as String?;
        } else if (id.startsWith('region')) {
          region = item['text'] as String?;
        }
      }
    }

    return GeocodingResult(
      placeName: json['place_name'] as String,
      address: json['text'] as String?,
      latitude: (coordinates[1] as num).toDouble(),
      longitude: (coordinates[0] as num).toDouble(),
      placeType: (json['place_type'] as List?)?.first as String?,
      country: country,
      region: region,
    );
  }

  /// Short display name (just the place name, not full address)
  String get shortName => address ?? placeName;

  /// Full display name (complete address)
  String get fullName => placeName;
}

/// Service for Mapbox Geocoding API
/// Provides location search and reverse geocoding functionality
class GeocodingService {
  static const String _baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
  final String _accessToken;
  final Dio _dio;

  GeocodingService({String? accessToken})
      : _accessToken = accessToken ?? Env.mapboxToken,
        _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Search for locations by query string
  ///
  /// [query] - The search query (e.g., "Toronto, Canada")
  /// [limit] - Maximum number of results to return (default: 5)
  /// [proximity] - Optional [longitude, latitude] to bias results near a location
  /// [types] - Optional filter by place types (e.g., ['place', 'region', 'country'])
  ///
  /// Returns a list of [GeocodingResult] objects
  Future<List<GeocodingResult>> searchLocation({
    required String query,
    int limit = 5,
    List<double>? proximity,
    List<String>? types,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final queryParameters = <String, dynamic>{
        'access_token': _accessToken,
        'limit': limit.toString(),
        if (proximity != null && proximity.length == 2)
          'proximity': '${proximity[0]},${proximity[1]}',
        if (types != null && types.isNotEmpty)
          'types': types.join(','),
      };

      final response = await _dio.get(
        '$_baseUrl/$encodedQuery.json',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>;

        return features
            .map((feature) => GeocodingResult.fromJson(feature as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Mapbox access token');
      } else {
        throw Exception('Geocoding API error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid Mapbox access token');
      }
      throw Exception('Failed to search location: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search location: $e');
    }
  }

  /// Reverse geocode coordinates to get place information
  ///
  /// [latitude] - The latitude coordinate
  /// [longitude] - The longitude coordinate
  /// [types] - Optional filter by place types
  ///
  /// Returns the first [GeocodingResult] or null if no results
  Future<GeocodingResult?> reverseGeocode({
    required double latitude,
    required double longitude,
    List<String>? types,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'access_token': _accessToken,
        'limit': '1',
        if (types != null && types.isNotEmpty)
          'types': types.join(','),
      };

      final response = await _dio.get(
        '$_baseUrl/$longitude,$latitude.json',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>;

        if (features.isNotEmpty) {
          return GeocodingResult.fromJson(features.first as Map<String, dynamic>);
        }
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Mapbox access token');
      } else {
        throw Exception('Reverse geocoding API error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid Mapbox access token');
      }
      throw Exception('Failed to reverse geocode: ${e.message}');
    } catch (e) {
      throw Exception('Failed to reverse geocode: $e');
    }
  }
}
