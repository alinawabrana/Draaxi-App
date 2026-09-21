import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecentPlacesStore {
  static const String _key = 'recent_places_v1';
  static const int _maxItems = 12;
  static const int _coordPrecision = 5;

  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    final list = decoded
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList(growable: false);
    final deduped = _dedupe(list).take(_maxItems).toList(growable: false);
    if (deduped.length != list.length) {
      await prefs.setString(_key, jsonEncode(deduped));
    }
    return deduped;
  }

  static Future<void> save(List<Map<String, dynamic>> places) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _dedupe(places).take(_maxItems).toList(growable: false);
    await prefs.setString(_key, jsonEncode(normalized));
  }

  static List<Map<String, dynamic>> _dedupe(List<Map<String, dynamic>> places) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final p in places) {
      final normalized = normalize(p);
      if (normalized == null) continue;
      final key = _placeKey(normalized);
      if (seen.add(key)) {
        result.add(normalized);
      }
    }
    return result;
  }

  static String _placeKey(Map<String, dynamic> place) {
    final placeId = (place['placeId'] as String?)?.trim();
    if (placeId != null && placeId.isNotEmpty) {
      return 'pid:$placeId';
    }

    final isCurrent =
        (place['isCurrent'] as bool?) == true ||
        ((place['name'] as String?)?.toLowerCase().trim() ==
            'current location');
    if (isCurrent) return 'current_location';

    final lat = (place['lat'] as num?)?.toDouble();
    final lng = (place['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) {
      final name = (place['name'] as String?)?.toLowerCase().trim() ?? '';
      final address = (place['address'] as String?)?.toLowerCase().trim() ?? '';
      return 'na:$name|$address';
    }

    final rLat = lat.toStringAsFixed(_coordPrecision);
    final rLng = lng.toStringAsFixed(_coordPrecision);
    return 'll:$rLat,$rLng';
  }

  static Map<String, dynamic>? normalize(Map<String, dynamic> place) {
    final name = (place['name'] as String?)?.trim() ?? '';
    final address = (place['address'] as String?)?.trim() ?? '';
    final lat = (place['lat'] as num?)?.toDouble();
    final lng = (place['lng'] as num?)?.toDouble();
    if (name.isEmpty || address.isEmpty || lat == null || lng == null) {
      return null;
    }
    final placeId = (place['placeId'] as String?)?.trim();
    final isCurrent = (place['isCurrent'] as bool?) == true;
    return <String, dynamic>{
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      if (placeId != null && placeId.isNotEmpty) 'placeId': placeId,
      if (isCurrent) 'isCurrent': true,
      'ts': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Future<List<Map<String, dynamic>>> add(
    Map<String, dynamic> place,
  ) async {
    final normalized = normalize(place);
    if (normalized == null) return load();
    final current = await load();
    final key = _placeKey(normalized);
    final next = <Map<String, dynamic>>[
      normalized,
      ...current.where((p) {
        return _placeKey(p) != key;
      }),
    ];
    await save(next);
    return next.take(_maxItems).toList(growable: false);
  }
}
