import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RiderApiRepository {
  RiderApiRepository({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://draaxi.com/api';
  static const String _authTokenKey = 'auth_token';

  final http.Client _client;

  String _maskAuth(String raw) {
    final token = raw.replaceFirst('Bearer ', '');
    if (token.length <= 10) return 'Bearer ***';
    return 'Bearer ${token.substring(0, 4)}***${token.substring(token.length - 4)}';
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    final auth = sanitized['Authorization'];
    if (auth != null && auth.isNotEmpty) {
      sanitized['Authorization'] = _maskAuth(auth);
    }
    return sanitized;
  }

  void _logRequest(
    String method,
    String path, {
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    debugPrint(
      '[RiderAPI][$method $path] HEADERS ${_sanitizeHeaders(headers)}',
    );
    if (body != null) {
      debugPrint('[RiderAPI][$method $path] BODY ${jsonEncode(body)}');
    }
  }

  void _logResponse(String method, String path, http.Response response) {
    debugPrint('[RiderAPI][$method $path] HTTP ${response.statusCode}');
    debugPrint('[RiderAPI][$method $path] RESPONSE ${response.body}');
  }

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_authTokenKey);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>?> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers();
    _logRequest('GET', path, headers: headers);
    final res = await _client.get(uri, headers: headers);
    _logResponse('GET', path, res);
    final body = _decodeBodyMap(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    debugPrint('[RiderAPI][GET $path] ${res.statusCode}: ${res.body}');
    return null;
  }

  Future<Map<String, dynamic>?> _post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers();
    _logRequest('POST', path, headers: headers, body: body);
    final res = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    _logResponse('POST', path, res);
    final decoded = _decodeBodyMap(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return decoded;
    debugPrint('[RiderAPI][POST $path] ${res.statusCode}: ${res.body}');
    return null;
  }

  Future<ApiCallResult> _postRaw(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers();
    _logRequest('POST', path, headers: headers, body: body);
    final res = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    _logResponse('POST', path, res);
    return ApiCallResult(
      statusCode: res.statusCode,
      body: _decodeBodyMap(res.body),
    );
  }

  Map<String, dynamic> _decodeBodyMap(String raw) {
    if (raw.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic> _dataRoot(Map<String, dynamic> map) {
    final dynamic data = map['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return map;
  }

  Future<bool> updateRiderLocation({
    required double lat,
    required double lng,
    double? heading,
    double? speed,
  }) async {
    final res = await _post(
      '/rider/location',
      body: <String, dynamic>{
        'lat': lat,
        'lng': lng,
        if (heading != null) 'heading': heading,
        if (speed != null) 'speed': speed,
      },
    );
    return res != null;
  }

  Future<RiderCurrentLocationData?> getCurrentRiderLocation() async {
    final res = await _get('/rider/location/current');
    if (res == null) return null;
    final root = _dataRoot(res);
    return RiderCurrentLocationData.fromJson(root);
  }

  Future<List<NearbyDriverData>> getNearbyDrivers({
    required double lat,
    required double lng,
    double radius = 5,
    String? rideType,
  }) async {
    final query = <String, String>{
      'lat': lat.toString(),
      'lng': lng.toString(),
      'radius': radius.toString(),
      if (rideType != null && rideType.isNotEmpty) 'ride_type': rideType,
    };
    final uri = Uri.parse(
      '$_baseUrl/rider/drivers/nearby',
    ).replace(queryParameters: query);
    final headers = await _headers();
    _logRequest('GET', '/rider/drivers/nearby?${uri.query}', headers: headers);
    final response = await _client.get(uri, headers: headers);
    _logResponse('GET', '/rider/drivers/nearby?${uri.query}', response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        '[RiderAPI][GET /rider/drivers/nearby] ${response.statusCode}: ${response.body}',
      );
      return const [];
    }

    final decoded = _decodeBodyMap(response.body);
    final dynamic listRaw = decoded['data'];
    if (listRaw is! List) return const [];
    return listRaw
        .whereType<Map>()
        .map((e) => NearbyDriverData.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<RideQuoteData?> getRideQuote({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    required String rideType,
  }) async {
    final res = await _post(
      '/rides/quote',
      body: <String, dynamic>{
        'pickup': <String, dynamic>{'lat': pickupLat, 'lng': pickupLng},
        'dropoff': <String, dynamic>{'lat': dropoffLat, 'lng': dropoffLng},
        'ride_type': rideType,
      },
    );
    if (res == null) return null;
    return RideQuoteData.fromJson(_dataRoot(res), rideType: rideType);
  }

  Future<CreateRideRequestResult?> createRideRequest({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    required String rideType,
    required double offeredFare,
  }) async {
    final res = await _postRaw(
      '/rides/requests',
      body: <String, dynamic>{
        'pickup': <String, dynamic>{'lat': pickupLat, 'lng': pickupLng},
        'dropoff': <String, dynamic>{'lat': dropoffLat, 'lng': dropoffLng},
        'ride_type': rideType,
        'offered_fare': offeredFare,
      },
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return CreateRideRequestResult.fromJson(_dataRoot(res.body));
    }
    final code = (res.body['error_code'] ?? '').toString();
    if (code == 'ACTIVE_REQUEST_EXISTS') {
      final requestId = (res.body['request_id'] ?? '').toString();
      if (requestId.isNotEmpty) {
        return CreateRideRequestResult(
          requestId: requestId,
          status: 'active_exists',
        );
      }
    }
    return null;
  }

  Future<RideRequestStatusResult?> getRideRequestStatus(
    String requestId,
  ) async {
    final res = await _get('/rides/requests/$requestId/status');
    if (res == null) return null;
    return RideRequestStatusResult.fromJson(_dataRoot(res));
  }

  Future<AcceptOfferResult?> acceptOffer(String offerId) async {
    final res = await _post('/rides/offers/$offerId/accept', body: const {});
    if (res == null) return null;
    return AcceptOfferResult.fromJson(_dataRoot(res));
  }

  Future<bool> declineOffer(String offerId) async {
    final res = await _post('/rides/offers/$offerId/decline', body: const {});
    return res != null;
  }

  Future<bool> _cancelRideEndpoint(String id) async {
    final res = await _post('/rides/$id/cancel', body: const {});
    return res != null;
  }

  Future<bool> cancelRide(String rideId) {
    return _cancelRideEndpoint(rideId);
  }

  Future<bool> cancelRideRequest(String requestId) {
    return _postRaw('/rides/requests/$requestId/cancel', body: const {}).then((
      res,
    ) {
      if (res.statusCode >= 200 && res.statusCode < 300) return true;
      final code = (res.body['error_code'] ?? '').toString().toUpperCase();
      if (code == 'REQUEST_NOT_FOUND' ||
          code == 'ACTIVE_REQUEST_NOT_FOUND' ||
          code == 'RIDE_NOT_FOUND') {
        // Treat already-cleared request as cancelled on client side.
        return true;
      }
      return false;
    });
  }

  void dispose() {
    _client.close();
  }
}

class RiderCurrentLocationData {
  const RiderCurrentLocationData({
    required this.lat,
    required this.lng,
    this.heading,
    this.speed,
  });

  final double lat;
  final double lng;
  final double? heading;
  final double? speed;

  factory RiderCurrentLocationData.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
    return RiderCurrentLocationData(
      lat: toDouble(json['lat']) ?? 0,
      lng: toDouble(json['lng']) ?? 0,
      heading: toDouble(json['heading']),
      speed: toDouble(json['speed']),
    );
  }
}

class NearbyDriverData {
  const NearbyDriverData({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.car,
    required this.rating,
  });

  final int id;
  final String name;
  final double lat;
  final double lng;
  final String car;
  final double rating;

  factory NearbyDriverData.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
    String? toNonEmptyString(dynamic v) {
      final value = (v ?? '').toString().trim();
      return value.isEmpty ? null : value;
    }
    final user =
        (json['user'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final vehicle =
        (json['vehicle'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final location =
        (json['location'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final vehicleDescription = toNonEmptyString(json['vehicle_description']);
    final vehicleType = toNonEmptyString(json['vehicle_type']);
    final vehicleNo = toNonEmptyString(json['vehicle_no']);
    final vehicleLabel = vehicleDescription ??
        [vehicleType, vehicleNo].whereType<String>().join(' ').trim();

    return NearbyDriverData(
      id: toInt(json['driver_id'] ?? json['id'] ?? user['id']),
      name:
          toNonEmptyString(json['driver_name']) ??
          toNonEmptyString(json['name']) ??
          toNonEmptyString(user['name']) ??
          'Driver',
      lat:
          toDouble(json['lat'] ?? json['latitude'] ?? location['lat']) ??
          toDouble(location['latitude']) ??
          0,
      lng:
          toDouble(json['lng'] ?? json['longitude'] ?? location['lng']) ??
          toDouble(location['longitude']) ??
          0,
      car:
          toNonEmptyString(json['car']) ??
          toNonEmptyString(vehicle['name']) ??
          (vehicleLabel.isEmpty ? 'Vehicle' : vehicleLabel),
      rating:
          toDouble(json['rating'] ?? json['driver_rating'] ?? user['rating']) ??
          toDouble(json['avg_rating']) ??
          0,
    );
  }
}

class RideQuoteData {
  const RideQuoteData({
    required this.rideType,
    required this.baseFare,
    required this.minimumFare,
    required this.recommendedFare,
    required this.distanceText,
    required this.durationText,
  });

  final String rideType;
  final double baseFare;
  final double minimumFare;
  final double recommendedFare;
  final String distanceText;
  final String durationText;

  factory RideQuoteData.fromJson(
    Map<String, dynamic> json, {
    required String rideType,
  }) {
    double? toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
    return RideQuoteData(
      rideType: rideType,
      baseFare: toDouble(json['base_fare']) ?? toDouble(json['baseFare']) ?? 0,
      minimumFare:
          toDouble(json['minimum_fare']) ?? toDouble(json['minimumFare']) ?? 0,
      recommendedFare:
          toDouble(json['recommended_fare']) ??
          toDouble(json['recommendedFare']) ??
          0,
      distanceText: (json['distance_text'] ?? json['distanceText'] ?? '')
          .toString(),
      durationText: (json['duration_text'] ?? json['durationText'] ?? '')
          .toString(),
    );
  }
}

class CreateRideRequestResult {
  const CreateRideRequestResult({
    required this.requestId,
    required this.status,
  });

  final String requestId;
  final String status;

  factory CreateRideRequestResult.fromJson(Map<String, dynamic> json) {
    String toId(dynamic v) => (v ?? '').toString();
    dynamic firstNonNull(List<dynamic> values) {
      for (final v in values) {
        if (v != null) return v;
      }
      return null;
    }

    final requestMap = (json['request'] as Map?)?.cast<String, dynamic>();
    final requestIdValue = firstNonNull(<dynamic>[
      json['request_id'],
      json['id'],
      requestMap?['request_id'],
      requestMap?['id'],
      (requestMap?['request'] as Map?)?['id'],
    ]);
    final statusValue = firstNonNull(<dynamic>[
      json['status'],
      requestMap?['status'],
      (requestMap?['request'] as Map?)?['status'],
    ]);
    return CreateRideRequestResult(
      requestId: toId(requestIdValue),
      status: (statusValue ?? 'searching').toString(),
    );
  }
}

class RideRequestStatusResult {
  const RideRequestStatusResult({
    required this.status,
    required this.offers,
    required this.hasAcceptedDriver,
    this.acceptedOffer,
    this.expiresAt,
  });

  final String status;
  final List<DriverOfferApiData> offers;
  final bool hasAcceptedDriver;
  final DriverOfferApiData? acceptedOffer;
  final DateTime? expiresAt;

  factory RideRequestStatusResult.fromJson(Map<String, dynamic> json) {
    dynamic firstNonNull(List<dynamic> values) {
      for (final v in values) {
        if (v != null) return v;
      }
      return null;
    }

    bool toBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final normalized = (value ?? '').toString().trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }

    final requestMap = (json['request'] as Map?)?.cast<String, dynamic>();
    DateTime? toDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    final offersRaw =
        firstNonNull(<dynamic>[
          json['pending_offers'],
          json['offers'],
          json['driver_offers'],
          requestMap?['pending_offers'],
          requestMap?['offers'],
          requestMap?['driver_offers'],
        ]) ??
        const [];
    final offers = offersRaw is List
        ? offersRaw
              .whereType<Map>()
              .map(
                (e) =>
                    DriverOfferApiData.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(growable: false)
        : const <DriverOfferApiData>[];
    final statusValue = firstNonNull(<dynamic>[
      json['status'],
      requestMap?['status'],
    ]);
    final expiresAtValue = firstNonNull(<dynamic>[
      json['expires_at'],
      json['expiresAt'],
      requestMap?['expires_at'],
      requestMap?['expiresAt'],
    ]);
    final acceptedOfferRaw = firstNonNull(<dynamic>[
      json['accepted_offer'],
      json['acceptedOffer'],
      requestMap?['accepted_offer'],
      requestMap?['acceptedOffer'],
    ]);
    return RideRequestStatusResult(
      status: (statusValue ?? '').toString(),
      offers: offers,
      hasAcceptedDriver: toBool(
        firstNonNull(<dynamic>[
          json['has_accepted_driver'],
          json['hasAcceptedDriver'],
          requestMap?['has_accepted_driver'],
          requestMap?['hasAcceptedDriver'],
        ]),
      ),
      acceptedOffer: acceptedOfferRaw is Map
          ? DriverOfferApiData.fromJson(Map<String, dynamic>.from(acceptedOfferRaw))
          : null,
      expiresAt: toDate(expiresAtValue),
    );
  }
}

class DriverOfferApiData {
  const DriverOfferApiData({
    required this.offerId,
    required this.driverId,
    required this.driverName,
    required this.rating,
    required this.vehicleName,
    required this.driverFare,
    required this.status,
    this.driverPhone,
    this.driverLat,
    this.driverLng,
    this.distanceToPickupMeters,
    this.etaToPickupSeconds,
    this.acceptedAt,
    this.expiresAt,
  });

  final String offerId;
  final int driverId;
  final String driverName;
  final double rating;
  final String vehicleName;
  final double driverFare;
  final String status;
  final String? driverPhone;
  final double? driverLat;
  final double? driverLng;
  final int? distanceToPickupMeters;
  final int? etaToPickupSeconds;
  final DateTime? acceptedAt;
  final DateTime? expiresAt;

  factory DriverOfferApiData.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
    String? toNonEmptyString(dynamic v) {
      final value = (v ?? '').toString().trim();
      return value.isEmpty ? null : value;
    }
    DateTime? toDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    final driver =
        (json['driver'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final vehicle =
        (json['vehicle'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final driverLocation =
        (json['driver_location'] as Map?)?.cast<String, dynamic>() ??
        (driver['location'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return DriverOfferApiData(
      offerId: (json['offer_id'] ?? json['id'] ?? '').toString(),
      driverId: toInt(json['driver_id'] ?? driver['id']),
      driverName: (json['driver_name'] ?? driver['name'] ?? 'Driver')
          .toString(),
      rating: toDouble(json['driver_rating'] ?? driver['rating']) ?? 4.7,
      vehicleName: (json['vehicle_name'] ?? vehicle['name'] ?? 'Car')
          .toString(),
      driverFare: toDouble(json['driver_fare'] ?? json['fare']) ?? 0,
      status: (json['status'] ?? '').toString(),
      driverPhone: toNonEmptyString(json['driver_phone'] ?? driver['phone']),
      driverLat: toDouble(
        json['driver_lat'] ??
            json['latitude'] ??
            driverLocation['lat'] ??
            driverLocation['latitude'],
      ),
      driverLng: toDouble(
        json['driver_lng'] ??
            json['longitude'] ??
            driverLocation['lng'] ??
            driverLocation['longitude'],
      ),
      distanceToPickupMeters: toInt(
        json['distance_to_pickup_meters'] ?? json['distance_meters'],
      ),
      etaToPickupSeconds: toInt(
        json['eta_to_pickup_seconds'] ?? json['eta_seconds'],
      ),
      acceptedAt: toDate(json['accepted_at'] ?? json['acceptedAt']),
      expiresAt: toDate(json['expires_at'] ?? json['expiresAt']),
    );
  }
}

class AcceptOfferResult {
  const AcceptOfferResult({
    required this.rideId,
    this.status,
    this.acceptedOffer,
  });

  final String rideId;
  final String? status;
  final DriverOfferApiData? acceptedOffer;

  factory AcceptOfferResult.fromJson(Map<String, dynamic> json) {
    final rideMap = (json['ride'] as Map?)?.cast<String, dynamic>();
    final driverMap = (json['driver'] as Map?)?.cast<String, dynamic>();
    final vehicleMap = (driverMap?['vehicle'] as Map?)?.cast<String, dynamic>();
    return AcceptOfferResult(
      rideId:
          (json['ride_id'] ??
                  json['id'] ??
                  rideMap?['ride_id'] ??
                  rideMap?['id'] ??
                  '')
              .toString(),
      status: (json['status'] ?? rideMap?['status'])?.toString(),
      acceptedOffer: driverMap == null
          ? null
          : DriverOfferApiData.fromJson(<String, dynamic>{
              'offer_id': json['offer_id'],
              'driver_id': json['driver_id'],
              'driver_name': driverMap['name'],
              'driver_phone': driverMap['phone'],
              'driver_rating': driverMap['rating'],
              'vehicle_name':
                  vehicleMap?['description'] ??
                  vehicleMap?['name'] ??
                  vehicleMap?['type'],
              'vehicle_type': vehicleMap?['type'],
              'vehicle_plate': vehicleMap?['plate'],
              'driver_fare': json['driver_fare'] ?? json['fare'],
              'status': 'accepted',
              'driver_location': driverMap['location'],
              'distance_to_pickup_meters': json['distance_to_pickup_meters'],
              'eta_to_pickup_seconds': json['eta_to_pickup_seconds'],
            }),
    );
  }
}

class ApiCallResult {
  const ApiCallResult({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, dynamic> body;
}
