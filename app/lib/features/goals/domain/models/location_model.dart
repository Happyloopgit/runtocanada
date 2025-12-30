import 'package:hive/hive.dart';

part 'location_model.g.dart';

@HiveType(typeId: 2)
class LocationModel extends HiveObject {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final String placeName;

  @HiveField(3)
  final String? address;

  @HiveField(4)
  final String? city;

  @HiveField(5)
  final String? country;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.placeName,
    this.address,
    this.city,
    this.country,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      placeName: json['placeName'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'placeName': placeName,
      'address': address,
      'city': city,
      'country': country,
    };
  }

  @override
  String toString() {
    return 'LocationModel(placeName: $placeName, lat: $latitude, lng: $longitude)';
  }
}
