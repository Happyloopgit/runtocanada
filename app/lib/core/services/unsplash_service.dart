import 'package:dio/dio.dart';
import '../../../app/env.dart';

/// Model representing an Unsplash photo
class UnsplashPhoto {
  final String id;
  final String description;
  final String? altDescription;
  final String regularUrl;
  final String smallUrl;
  final String thumbUrl;
  final String authorName;
  final String authorUsername;

  UnsplashPhoto({
    required this.id,
    required this.description,
    this.altDescription,
    required this.regularUrl,
    required this.smallUrl,
    required this.thumbUrl,
    required this.authorName,
    required this.authorUsername,
  });

  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) {
    final urls = json['urls'] as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>;

    return UnsplashPhoto(
      id: json['id'] as String,
      description: json['description'] as String? ?? '',
      altDescription: json['alt_description'] as String?,
      regularUrl: urls['regular'] as String,
      smallUrl: urls['small'] as String,
      thumbUrl: urls['thumb'] as String,
      authorName: user['name'] as String,
      authorUsername: user['username'] as String,
    );
  }

  /// Get display description (prefer alt_description)
  String get displayDescription => altDescription ?? description;
}

/// Service for Unsplash API
/// Fetches photos for cities and locations
class UnsplashService {
  static const String _baseUrl = 'https://api.unsplash.com';
  final String _accessKey;
  final Dio _dio;

  UnsplashService({String? accessKey})
      : _accessKey = accessKey ?? Env.unsplashKey,
        _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Search for photos by query
  ///
  /// [query] - Search query (e.g., "Toronto skyline", "Vancouver Canada")
  /// [page] - Page number (default: 1)
  /// [perPage] - Number of results per page (default: 1, max: 30)
  /// [orientation] - Photo orientation ('landscape', 'portrait', 'squarish')
  ///
  /// Returns a list of [UnsplashPhoto] objects
  Future<List<UnsplashPhoto>> searchPhotos({
    required String query,
    int page = 1,
    int perPage = 1,
    String? orientation,
  }) async {
    if (_accessKey.isEmpty) {
      // Return empty list if no API key configured
      return [];
    }

    try {
      final queryParameters = <String, dynamic>{
        'query': query,
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (orientation != null) 'orientation': orientation,
      };

      final response = await _dio.get(
        '$_baseUrl/search/photos',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Authorization': 'Client-ID $_accessKey',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        return results
            .map((photo) => UnsplashPhoto.fromJson(photo as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Unsplash API key');
      } else {
        throw Exception('Unsplash API error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid Unsplash API key');
      }
      // Return empty list on error (graceful degradation)
      return [];
    } catch (e) {
      // Return empty list on error (graceful degradation)
      return [];
    }
  }

  /// Search for city skyline photo
  ///
  /// [cityName] - Name of the city (e.g., "Toronto", "Vancouver")
  /// [country] - Optional country name for better results
  ///
  /// Returns the first [UnsplashPhoto] or null if none found
  Future<UnsplashPhoto?> getCitySkylinePhoto({
    required String cityName,
    String? country,
  }) async {
    final query = country != null
        ? '$cityName $country skyline'
        : '$cityName skyline';

    final photos = await searchPhotos(
      query: query,
      perPage: 1,
      orientation: 'landscape',
    );

    return photos.isNotEmpty ? photos.first : null;
  }

  /// Search for city landmark photo
  ///
  /// [cityName] - Name of the city
  /// [country] - Optional country name
  ///
  /// Returns the first [UnsplashPhoto] or null if none found
  Future<UnsplashPhoto?> getCityLandmarkPhoto({
    required String cityName,
    String? country,
  }) async {
    final query = country != null
        ? '$cityName $country landmark'
        : '$cityName landmark';

    final photos = await searchPhotos(
      query: query,
      perPage: 1,
      orientation: 'landscape',
    );

    return photos.isNotEmpty ? photos.first : null;
  }

  /// Search for generic city photo
  ///
  /// [cityName] - Name of the city
  /// [country] - Optional country name
  ///
  /// Returns the first [UnsplashPhoto] or null if none found
  Future<UnsplashPhoto?> getCityPhoto({
    required String cityName,
    String? country,
  }) async {
    final query = country != null
        ? '$cityName $country'
        : cityName;

    final photos = await searchPhotos(
      query: query,
      perPage: 1,
      orientation: 'landscape',
    );

    return photos.isNotEmpty ? photos.first : null;
  }
}
