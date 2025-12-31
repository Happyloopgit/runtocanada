import 'package:dio/dio.dart';

/// Model representing a Wikipedia page summary
class WikipediaSummary {
  final String title;
  final String extract;
  final String? description;
  final String? thumbnailUrl;
  final String pageUrl;

  WikipediaSummary({
    required this.title,
    required this.extract,
    this.description,
    this.thumbnailUrl,
    required this.pageUrl,
  });

  factory WikipediaSummary.fromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'] as Map<String, dynamic>?;

    return WikipediaSummary(
      title: json['title'] as String,
      extract: json['extract'] as String,
      description: json['description'] as String?,
      thumbnailUrl: thumbnail?['source'] as String?,
      pageUrl: json['content_urls']['desktop']['page'] as String,
    );
  }

  /// Get short description (first 200 characters)
  String get shortExtract {
    if (extract.length <= 200) {
      return extract;
    }
    final cutoff = extract.substring(0, 200).lastIndexOf(' ');
    return '${extract.substring(0, cutoff)}...';
  }
}

/// Service for Wikipedia API
/// Fetches page summaries and descriptions for cities
class WikipediaService {
  static const String _baseUrl = 'https://en.wikipedia.org/api/rest_v1/page/summary';
  final Dio _dio;

  WikipediaService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Get Wikipedia summary for a location
  ///
  /// [locationName] - Name of the location (e.g., "Toronto", "Vancouver, British Columbia")
  ///
  /// Returns a [WikipediaSummary] or null if not found
  Future<WikipediaSummary?> getLocationSummary({
    required String locationName,
  }) async {
    try {
      // Replace spaces with underscores for Wikipedia URLs
      final encodedName = Uri.encodeComponent(locationName.replaceAll(' ', '_'));

      final response = await _dio.get(
        '$_baseUrl/$encodedName',
        options: Options(
          headers: {
            'Api-User-Agent': 'RunToCanada/1.0 (https://runtocanada.app)',
          },
        ),
      );

      if (response.statusCode == 200) {
        return WikipediaSummary.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        // Page not found, return null
        return null;
      } else {
        throw Exception('Wikipedia API error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Page not found, return null
        return null;
      }
      // Return null on error (graceful degradation)
      return null;
    } catch (e) {
      // Return null on error (graceful degradation)
      return null;
    }
  }

  /// Get Wikipedia summary for a city
  ///
  /// [cityName] - Name of the city
  /// [region] - Optional region/province/state
  /// [country] - Optional country
  ///
  /// Returns a [WikipediaSummary] or null if not found
  Future<WikipediaSummary?> getCitySummary({
    required String cityName,
    String? region,
    String? country,
  }) async {
    // Try different query formats to find the Wikipedia page
    final queries = <String>[];

    // Try with region and country
    if (region != null && country != null) {
      queries.add('$cityName, $region, $country');
    }

    // Try with region only
    if (region != null) {
      queries.add('$cityName, $region');
    }

    // Try with country only
    if (country != null) {
      queries.add('$cityName, $country');
    }

    // Try with just city name
    queries.add(cityName);

    // Try each query format until we find a result
    for (final query in queries) {
      final summary = await getLocationSummary(locationName: query);
      if (summary != null) {
        return summary;
      }
    }

    return null;
  }

  /// Search Wikipedia for pages matching a query
  ///
  /// [query] - Search query
  /// [limit] - Maximum number of results (default: 5)
  ///
  /// Returns a list of page titles
  Future<List<String>> searchPages({
    required String query,
    int limit = 5,
  }) async {
    try {
      final searchUrl = 'https://en.wikipedia.org/w/api.php';
      final response = await _dio.get(
        searchUrl,
        queryParameters: {
          'action': 'opensearch',
          'format': 'json',
          'search': query,
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        if (data.length >= 2) {
          final titles = data[1] as List<dynamic>;
          return titles.map((title) => title as String).toList();
        }
      }

      return [];
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }
}
