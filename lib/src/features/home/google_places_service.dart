import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleApiKeys {
  const GoogleApiKeys({required this.mapsApiKey, required this.placesApiKey});

  final String mapsApiKey;
  final String placesApiKey;

  static const MethodChannel _channel = MethodChannel(
    'com.example.draaxi/google_api_keys',
  );

  static Future<GoogleApiKeys> load() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return const GoogleApiKeys(mapsApiKey: '', placesApiKey: '');
    }

    final dynamic raw = await _channel.invokeMethod('getKeys');
    final map = Map<String, dynamic>.from(raw as Map);
    final mapsApiKey = (map['mapsApiKey'] as String?) ?? '';
    final placesApiKey = (map['placesApiKey'] as String?) ?? mapsApiKey;
    return GoogleApiKeys(mapsApiKey: mapsApiKey, placesApiKey: placesApiKey);
  }
}

class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structured =
        (json['structured_formatting'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return PlacePrediction(
      placeId: (json['place_id'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      mainText: (structured['main_text'] as String?) ?? '',
      secondaryText: (structured['secondary_text'] as String?) ?? '',
    );
  }
}

class PlaceDetails {
  const PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  final String placeId;
  final String name;
  final String formattedAddress;
  final double lat;
  final double lng;
}

class GooglePlacesService {
  GooglePlacesService({required String apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  final String _apiKey;
  final http.Client _client;

  static Future<GooglePlacesService> create() async {
    final keys = await GoogleApiKeys.load();
    return GooglePlacesService(apiKey: keys.placesApiKey);
  }

  Future<List<PlacePrediction>> autocomplete({
    required String input,
    required String sessionToken,
    String? language,
    String? components,
    LatLng? location,
    int? radiusMeters,
  }) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty || _apiKey.isEmpty) return const [];

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      <String, String>{
        'input': trimmed,
        'key': _apiKey,
        'sessiontoken': sessionToken,
        if (language != null) 'language': language,
        if (components != null) 'components': components,
        if (location != null)
          'location': '${location.latitude},${location.longitude}',
        if (radiusMeters != null) 'radius': radiusMeters.toString(),
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) return const [];

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final status = (decoded['status'] as String?) ?? '';
    if (status != 'OK') return const [];

    final predictions =
        (decoded['predictions'] as List?)?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];

    return predictions.map(PlacePrediction.fromJson).toList(growable: false);
  }

  Future<PlaceDetails?> placeDetails({
    required String placeId,
    required String sessionToken,
    String? language,
  }) async {
    final trimmed = placeId.trim();
    if (trimmed.isEmpty || _apiKey.isEmpty) return null;

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      <String, String>{
        'place_id': trimmed,
        'key': _apiKey,
        'sessiontoken': sessionToken,
        'fields': 'place_id,name,formatted_address,geometry/location',
        if (language != null) 'language': language,
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) return null;

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final status = (decoded['status'] as String?) ?? '';
    if (status != 'OK') return null;

    final result = (decoded['result'] as Map?)?.cast<String, dynamic>();
    if (result == null) return null;

    final geometry =
        (result['geometry'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final location =
        (geometry['location'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    final lat = (location['lat'] as num?)?.toDouble();
    final lng = (location['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    return PlaceDetails(
      placeId: (result['place_id'] as String?) ?? trimmed,
      name: (result['name'] as String?) ?? '',
      formattedAddress: (result['formatted_address'] as String?) ?? '',
      lat: lat,
      lng: lng,
    );
  }

  void dispose() {
    _client.close();
  }
}

class DirectionsRoute {
  const DirectionsRoute({
    required this.points,
    required this.bounds,
    required this.distanceMeters,
    required this.distanceText,
    required this.durationSeconds,
    required this.durationText,
  });

  final List<LatLng> points;
  final LatLngBounds bounds;
  final int distanceMeters;
  final String distanceText;
  final int durationSeconds;
  final String durationText;
}

class GoogleDirectionsService {
  GoogleDirectionsService({required String apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  final String _apiKey;
  final http.Client _client;

  static Future<GoogleDirectionsService> create() async {
    final keys = await GoogleApiKeys.load();
    return GoogleDirectionsService(apiKey: keys.mapsApiKey);
  }

  Future<DirectionsRoute?> directions({
    required LatLng origin,
    required LatLng destination,
    String? language,
    String mode = 'driving',
  }) async {
    if (_apiKey.isEmpty) return null;

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      <String, String>{
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': _apiKey,
        'mode': mode,
        if (language != null) 'language': language,
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) return null;

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final status = (decoded['status'] as String?) ?? '';
    if (status != 'OK') return null;

    final routes =
        (decoded['routes'] as List?)?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    if (routes.isEmpty) return null;

    final first = routes.first;
    final overview =
        (first['overview_polyline'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final pointsEncoded = (overview['points'] as String?) ?? '';
    if (pointsEncoded.isEmpty) return null;

    final boundsJson = (first['bounds'] as Map?)?.cast<String, dynamic>();
    final bounds = _boundsFromJson(boundsJson);
    final points = _decodePolyline(pointsEncoded);
    if (points.isEmpty) return null;

    final distance = _totalDistance(first);
    final duration = _totalDuration(first);

    return DirectionsRoute(
      points: points,
      bounds: bounds,
      distanceMeters: distance,
      distanceText: _formatDistance(distance),
      durationSeconds: duration,
      durationText: _formatDuration(duration),
    );
  }

  int _totalDistance(Map<String, dynamic> routeJson) {
    final legs =
        (routeJson['legs'] as List?)?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    if (legs.isEmpty) return 0;

    var total = 0;
    for (final leg in legs) {
      final distance =
          (leg['distance'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
      total += (distance['value'] as num?)?.round() ?? 0;
    }
    return total;
  }

  int _totalDuration(Map<String, dynamic> routeJson) {
    final legs =
        (routeJson['legs'] as List?)?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    if (legs.isEmpty) return 0;

    var total = 0;
    for (final leg in legs) {
      final duration =
          (leg['duration'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
      total += (duration['value'] as num?)?.round() ?? 0;
    }
    return total;
  }

  String _formatDistance(int meters) {
    if (meters <= 0) return '';
    if (meters < 1000) return '$meters m';
    final km = meters / 1000.0;
    if (km >= 10) return '${km.round()} km';
    return '${km.toStringAsFixed(1)} km';
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '';
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remMin = minutes % 60;
    if (remMin == 0) return '$hours hr';
    return '$hours hr $remMin min';
  }

  LatLngBounds _boundsFromJson(Map<String, dynamic>? json) {
    final ne = (json?['northeast'] as Map?)?.cast<String, dynamic>();
    final sw = (json?['southwest'] as Map?)?.cast<String, dynamic>();
    final neLat = (ne?['lat'] as num?)?.toDouble() ?? 0;
    final neLng = (ne?['lng'] as num?)?.toDouble() ?? 0;
    final swLat = (sw?['lat'] as num?)?.toDouble() ?? 0;
    final swLng = (sw?['lng'] as num?)?.toDouble() ?? 0;

    final northeast = LatLng(neLat, neLng);
    final southwest = LatLng(swLat, swLng);

    final safeSw = LatLng(
      southwest.latitude <= northeast.latitude
          ? southwest.latitude
          : northeast.latitude,
      southwest.longitude <= northeast.longitude
          ? southwest.longitude
          : northeast.longitude,
    );
    final safeNe = LatLng(
      northeast.latitude >= southwest.latitude
          ? northeast.latitude
          : southwest.latitude,
      northeast.longitude >= southwest.longitude
          ? northeast.longitude
          : southwest.longitude,
    );

    return LatLngBounds(southwest: safeSw, northeast: safeNe);
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  void dispose() {
    _client.close();
  }
}

class DeviceLocationService {
  static Future<LatLng?> getCurrentLatLng() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final last = await Geolocator.getLastKnownPosition();
        if (last == null) return null;
        return LatLng(last.latitude, last.longitude);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final last = await Geolocator.getLastKnownPosition();
        if (last == null) return null;
        return LatLng(last.latitude, last.longitude);
      }

      const settings = LocationSettings(accuracy: LocationAccuracy.high);
      final position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      );
      return LatLng(position.latitude, position.longitude);
    } on MissingPluginException {
      return null;
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last == null) return null;
      return LatLng(last.latitude, last.longitude);
    }
  }
}
