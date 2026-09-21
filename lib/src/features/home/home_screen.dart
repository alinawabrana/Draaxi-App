import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:draaxi/src/common/widgets/app_drawer.dart';
import 'package:draaxi/src/features/home/address_selection_sheet.dart';
import 'package:draaxi/src/features/home/google_places_service.dart';
import 'package:draaxi/src/features/home/rider_api_repository.dart';
import 'package:draaxi/src/features/wallet/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum _BookingStep { main, chooseRide, selectDriver, driverComing }

enum _TripProgress { driverComing, driverReached, rideStarted, rideCompleted }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const String _nightMapStyle =
      '[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6b9a76"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f2835"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#f3d19c"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},{"featureType":"transit.station","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]},{"featureType":"water","elementType":"labels.text.stroke","stylers":[{"color":"#17263c"}]}]';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RiderApiRepository _riderApiRepository = RiderApiRepository();
  int _selectedService = 0; // 0 for Transport, 1 for Delivery
  final LatLng _currentLocation = const LatLng(
    37.7749,
    -122.4194,
  ); // Default location
  LatLng _userLiveLocation = const LatLng(37.7749, -122.4194);
  GoogleMapController? _googleMapController;
  LatLngBounds? _pendingRouteBounds;
  LatLng? _pendingInitialCameraTarget;
  Timer? _mapStyleTimer;
  bool _timeNight = false;
  BitmapDescriptor? _nearbyCarMarkerIcon;
  BitmapDescriptor? _userLocationMarkerIcon;
  Map<int, NearbyDriverData> _nearbyDriversById =
      const <int, NearbyDriverData>{};

  Map<String, dynamic>? _fromPlace;
  Map<String, dynamic>? _toPlace;
  Set<Marker> _routeMarkers = const <Marker>{};
  Set<Marker> _nearbyDriverMarkers = const <Marker>{};
  Set<Polyline> _polylines = const <Polyline>{};
  String? _routeDistanceText;
  int? _routeDistanceMeters;
  String? _selectedRideOptionId;
  Map<String, String> _rideEtaTexts = const <String, String>{};
  int _routeRequestId = 0;
  _BookingStep _bookingStep = _BookingStep.main;
  double _selectedFare = 0;
  final List<_PendingDriverOffer> _pendingDriverOffers =
      <_PendingDriverOffer>[];
  final List<Timer> _scheduledIncomingOfferTimers = <Timer>[];
  Timer? _driverOfferTicker;
  int _driverRequestSeq = 0;
  Timer? _driverApproachTimer;
  bool _isRideBottomSheetVisible = true;
  bool _isDriverDetailBottomSheetCollapsed = false;
  Timer? _rideRequestStatusTimer;
  bool _isSubmittingRideRequest = false;
  String? _activeRideRequestId;
  String? _activeRideId;
  RideQuoteData? _backendQuote;
  _DriverOffer? _confirmedOffer;
  LatLng? _confirmedDriverLocation;
  LatLng? _confirmedRiderLocation;
  int _confirmedDriverDistanceMeters = 0;
  String _confirmedDriverEtaText = '';
  int _confirmedArrivalSeconds = 0;
  _TripProgress _tripProgress = _TripProgress.driverComing;
  bool _hasChargedCompletedRide = false;

  @override
  void initState() {
    super.initState();
    _nearbyDriverMarkers = const <Marker>{};
    Future.microtask(() {
      ref.read(walletProvider.notifier).ensureInitialized();
    });
    unawaited(_initCustomMarkerIcons());
    unawaited(_initDeviceLocation());
    _timeNight = _isNightByTime();
    _mapStyleTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final next = _isNightByTime();
      if (next == _timeNight) return;
      _timeNight = next;
      if (mounted) setState(() {});
    });
  }

  bool _isNightByTime() {
    final hour = DateTime.now().hour;
    return hour >= 18 || hour < 6;
  }

  bool _shouldUseNightStyle(Brightness brightness) {
    if (brightness == Brightness.dark) return true;
    return _timeNight;
  }

  Future<void> _initDeviceLocation() async {
    final latLng = await DeviceLocationService.getCurrentLatLng();
    if (!mounted) return;
    if (latLng == null) {
      final fromApi = await _riderApiRepository.getCurrentRiderLocation();
      if (!mounted || fromApi == null) return;
      final fallback = LatLng(fromApi.lat, fromApi.lng);
      setState(() {
        _userLiveLocation = fallback;
        if (_bookingStep == _BookingStep.main) {
          _nearbyDriverMarkers = const <Marker>{};
        }
      });
      unawaited(_syncLocationAndNearbyDrivers(fallback));
      return;
    }
    setState(() {
      _userLiveLocation = latLng;
      if (_bookingStep == _BookingStep.main) {
        _nearbyDriverMarkers = const <Marker>{};
      }
    });
    unawaited(_syncLocationAndNearbyDrivers(latLng));

    final controller = _googleMapController;
    if (controller == null) {
      setState(() {
        _pendingInitialCameraTarget = latLng;
      });
      return;
    }

    await controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
  }

  Future<void> _syncLocationAndNearbyDrivers(
    LatLng location, {
    String? rideType,
  }) async {
    await _riderApiRepository.updateRiderLocation(
      lat: location.latitude,
      lng: location.longitude,
    );
    final nearby = await _riderApiRepository.getNearbyDrivers(
      lat: location.latitude,
      lng: location.longitude,
      radius: 5,
      rideType: rideType,
    );
    if (!mounted) return;
    setState(() {
      _nearbyDriversById = {for (final driver in nearby) driver.id: driver};
      _nearbyDriverMarkers = _buildNearbyDriverMarkersFromApi(nearby);
    });
  }

  Future<void> _recenterToCurrentLocation() async {
    final latest = await DeviceLocationService.getCurrentLatLng();
    final target = latest ?? _userLiveLocation;
    if (!mounted) return;

    if (latest != null) {
      setState(() {
        _userLiveLocation = latest;
        if (_bookingStep == _BookingStep.main) {
          _nearbyDriverMarkers = const <Marker>{};
        }
      });
      unawaited(_syncLocationAndNearbyDrivers(latest));
    }

    final controller = _googleMapController;
    if (controller == null) {
      setState(() {
        _pendingInitialCameraTarget = target;
      });
      return;
    }

    double zoom = 15;
    try {
      zoom = await controller.getZoomLevel();
    } catch (_) {
      // Keep fallback zoom when current zoom cannot be retrieved.
    }
    await controller.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }

  Future<void> _initCustomMarkerIcons() async {
    try {
      final nearby = await _createCarMarkerDescriptor(
        color: const Color(0xFFEDAE10),
      );
      final userLocation = await _createUserLocationMarkerDescriptor(
        color: const Color(0xFF1A73E8),
      );
      if (!mounted) return;
      setState(() {
        _nearbyCarMarkerIcon = nearby;
        _userLocationMarkerIcon = userLocation;
      });
    } catch (_) {
      // Keep default marker fallback when custom icon generation fails.
    }
  }

  Future<BitmapDescriptor> _createCarMarkerDescriptor({
    required Color color,
  }) async {
    const markerSize = 70.0;
    const iconSize = 36.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(markerSize / 2, markerSize / 2);

    final haloPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, markerSize * 0.42, haloPaint);

    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, markerSize * 0.3, bodyPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2;
    canvas.drawCircle(center, markerSize * 0.3, borderPaint);

    final painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: String.fromCharCode(Icons.directions_car.codePoint),
      style: TextStyle(
        fontSize: iconSize,
        fontFamily: Icons.directions_car.fontFamily,
        package: Icons.directions_car.fontPackage,
        color: Colors.white,
      ),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );

    final image = await recorder.endRecording().toImage(
      markerSize.toInt(),
      markerSize.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = bytes?.buffer.asUint8List();
    if (pngBytes == null) return BitmapDescriptor.defaultMarker;
    return BitmapDescriptor.bytes(pngBytes);
  }

  Future<BitmapDescriptor> _createUserLocationMarkerDescriptor({
    required Color color,
  }) async {
    const markerSize = 260.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(markerSize / 2, markerSize / 2);

    final outerRingPaint = Paint()
      ..color = const Color(0x1AFEC400)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 108, outerRingPaint);

    final middleRingPaint = Paint()
      ..color = const Color(0x26FEC400)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 74, middleRingPaint);

    final innerRingPaint = Paint()
      ..color = const Color(0x40FEC400)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 35, innerRingPaint);

    final centerPaint = Paint()
      ..color = const Color(0xFFFECC36)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, centerPaint);

    final painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: String.fromCharCode(Icons.location_on.codePoint),
      style: TextStyle(
        fontSize: 18,
        fontFamily: Icons.location_on.fontFamily,
        package: Icons.location_on.fontPackage,
        color: const Color(0xFF414141),
      ),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );

    final image = await recorder.endRecording().toImage(
      markerSize.toInt(),
      markerSize.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = bytes?.buffer.asUint8List();
    if (pngBytes == null) return BitmapDescriptor.defaultMarker;
    return BitmapDescriptor.bytes(pngBytes);
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    _clearPendingDriverRequests();
    _rideRequestStatusTimer?.cancel();
    _driverApproachTimer?.cancel();
    _mapStyleTimer?.cancel();
    _riderApiRepository.dispose();
    super.dispose();
  }

  void _openAddressSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressSelectionSheet(
        initialFromPlace: _fromPlace,
        initialToPlace: _toPlace,
        onConfirm: (from, to) {
          setState(() {
            _fromPlace = from;
            _toPlace = to;
            _selectedRideOptionId ??= 'bike';
            _bookingStep = _BookingStep.chooseRide;
            _isRideBottomSheetVisible = true;
            _clearPendingDriverRequests();
          });
          _refreshRoute();
        },
      ),
    );
  }

  void _exitRideSelection() {
    setState(() {
      _bookingStep = _BookingStep.main;
      _fromPlace = null;
      _toPlace = null;
      _selectedRideOptionId = null;
      _rideEtaTexts = const <String, String>{};
      _routeDistanceText = null;
      _routeDistanceMeters = null;
      _routeMarkers = const <Marker>{};
      _nearbyDriverMarkers = const <Marker>{};
      _polylines = const <Polyline>{};
      _pendingRouteBounds = null;
      _selectedFare = 0;
      _clearPendingDriverRequests();
      _isRideBottomSheetVisible = true;
      _isSubmittingRideRequest = false;
      _activeRideRequestId = null;
      _activeRideId = null;
      _backendQuote = null;
      _confirmedOffer = null;
      _confirmedDriverLocation = null;
      _confirmedRiderLocation = null;
      _confirmedDriverDistanceMeters = 0;
      _confirmedDriverEtaText = '';
      _confirmedArrivalSeconds = 0;
      _tripProgress = _TripProgress.driverComing;
      _hasChargedCompletedRide = false;
      _isDriverDetailBottomSheetCollapsed = false;
    });
    _rideRequestStatusTimer?.cancel();
    _driverApproachTimer?.cancel();
    unawaited(_syncLocationAndNearbyDrivers(_userLiveLocation));
  }

  void _goBackInBookingFlow() {
    if (_bookingStep == _BookingStep.selectDriver) {
      _rideRequestStatusTimer?.cancel();
      setState(() {
        _bookingStep = _BookingStep.chooseRide;
        _isRideBottomSheetVisible = true;
        _clearPendingDriverRequests();
      });
      return;
    }
    if (_bookingStep == _BookingStep.driverComing) {
      _exitRideSelection();
      return;
    }
    if (_bookingStep == _BookingStep.chooseRide) {
      _exitRideSelection();
      return;
    }
    _scaffoldKey.currentState?.openDrawer();
  }

  void _handleSystemBack() {
    if (_bookingStep == _BookingStep.selectDriver) {
      _goBackInBookingFlow();
      return;
    }
    if (_bookingStep == _BookingStep.driverComing) {
      _goBackInBookingFlow();
      return;
    }
    if (_bookingStep == _BookingStep.chooseRide) {
      _goBackInBookingFlow();
      return;
    }
  }

  Future<void> _refreshRoute() async {
    final requestId = ++_routeRequestId;
    final from = _fromPlace;
    final to = _toPlace;
    final fromLat = (from?['lat'] as num?)?.toDouble();
    final fromLng = (from?['lng'] as num?)?.toDouble();
    final toLat = (to?['lat'] as num?)?.toDouble();
    final toLng = (to?['lng'] as num?)?.toDouble();

    if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
      setState(() {
        _routeMarkers = const <Marker>{};
        _polylines = const <Polyline>{};
        _routeDistanceText = null;
        _routeDistanceMeters = null;
        _rideEtaTexts = const <String, String>{};
        _nearbyDriverMarkers = const <Marker>{};
        _backendQuote = null;
        _clearPendingDriverRequests();
      });
      return;
    }

    final origin = LatLng(fromLat, fromLng);
    final destination = LatLng(toLat, toLng);

    final directions = await GoogleDirectionsService.create();
    final route = await directions.directions(
      origin: origin,
      destination: destination,
      mode: 'driving',
    );
    if (!mounted || requestId != _routeRequestId) {
      directions.dispose();
      return;
    }

    if (route == null) {
      final approxMeters = _haversineDistanceMeters(origin, destination);
      final carSeconds = _estimateDurationSeconds(approxMeters, speedKmh: 35);
      final bikeSeconds = _estimateDurationSeconds(approxMeters, speedKmh: 15);
      setState(() {
        _routeMarkers = {
          Marker(markerId: const MarkerId('from'), position: origin),
          Marker(markerId: const MarkerId('to'), position: destination),
        };
        _polylines = const <Polyline>{};
        _routeDistanceText = _formatDistance(approxMeters);
        _routeDistanceMeters = approxMeters;
        _rideEtaTexts = <String, String>{
          'bike': _formatDuration(bikeSeconds),
          'mini': _formatDuration(carSeconds),
          'ac': _formatDuration(carSeconds),
        };
        _nearbyDriverMarkers = const <Marker>{};
        _resetSelectedFare();
        _backendQuote = null;
        _clearPendingDriverRequests();
      });
      unawaited(_loadRideQuoteForSelection());
      unawaited(_syncLocationAndNearbyDrivers(origin, rideType: _apiRideType));
      directions.dispose();
      return;
    }

    final markers = <Marker>{
      Marker(markerId: const MarkerId('from'), position: origin),
      Marker(markerId: const MarkerId('to'), position: destination),
    };
    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route'),
        points: route.points,
        color: const Color(0xFFEDAE10),
        width: 5,
      ),
    };

    setState(() {
      _routeMarkers = markers;
      _polylines = polylines;
      _routeDistanceText = route.distanceText.isEmpty
          ? null
          : route.distanceText;
      _routeDistanceMeters = route.distanceMeters;
      _rideEtaTexts = <String, String>{
        'mini': route.durationText,
        'ac': route.durationText,
      };
      _nearbyDriverMarkers = const <Marker>{};
      _resetSelectedFare();
      _backendQuote = null;
      _clearPendingDriverRequests();
    });
    unawaited(_loadRideQuoteForSelection());
    unawaited(_syncLocationAndNearbyDrivers(origin, rideType: _apiRideType));

    final bikeRoute = await directions.directions(
      origin: origin,
      destination: destination,
      mode: 'bicycling',
    );
    directions.dispose();

    if (!mounted || requestId != _routeRequestId) return;

    final bikeEta = bikeRoute?.durationText.isNotEmpty == true
        ? bikeRoute!.durationText
        : _formatDuration(
            _estimateDurationSeconds(route.distanceMeters, speedKmh: 15),
          );
    setState(() {
      _rideEtaTexts = <String, String>{..._rideEtaTexts, 'bike': bikeEta};
    });

    final controller = _googleMapController;
    if (controller == null) {
      _pendingRouteBounds = route.bounds;
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(route.bounds, 64),
    );
  }

  int _haversineDistanceMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLng = _degToRad(b.longitude - a.longitude);
    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);
    final sinDLat = math.sin(dLat / 2);
    final sinDLng = math.sin(dLng / 2);
    final h =
        sinDLat * sinDLat + math.cos(lat1) * math.cos(lat2) * sinDLng * sinDLng;
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return (earthRadius * c).round();
  }

  double _degToRad(double deg) => deg * math.pi / 180.0;

  String _formatDistance(int meters) {
    if (meters <= 0) return '';
    if (meters < 1000) return '$meters m';
    final km = meters / 1000.0;
    if (km >= 10) return '${km.round()} km';
    return '${km.toStringAsFixed(1)} km';
  }

  int _estimateDurationSeconds(int meters, {required int speedKmh}) {
    if (meters <= 0 || speedKmh <= 0) return 0;
    final speedMetersPerSecond = speedKmh * 1000 / 3600;
    return (meters / speedMetersPerSecond).round();
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

  String _formatArrivalClock(int seconds) {
    if (seconds <= 0) return '0:00';
    final mins = seconds ~/ 60;
    final rem = seconds % 60;
    return '$mins:${rem.toString().padLeft(2, '0')}';
  }

  LatLng? get _dropoffLatLng {
    final to = _toPlace;
    final lat = (to?['lat'] as num?)?.toDouble();
    final lng = (to?['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  bool get _isTripInProgress =>
      _tripProgress == _TripProgress.rideStarted ||
      _tripProgress == _TripProgress.rideCompleted;

  Set<Marker> _buildNearbyDriverMarkersFromApi(List<NearbyDriverData> drivers) {
    return drivers.map((driver) {
      return Marker(
        markerId: MarkerId('nearby_driver_api_${driver.id}'),
        position: LatLng(driver.lat, driver.lng),
        icon:
            _nearbyCarMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: driver.name,
          snippet: '${driver.car} • ★ ${driver.rating.toStringAsFixed(1)}',
        ),
      );
    }).toSet();
  }

  Marker? _buildUserLocationMarker() {
    if (_bookingStep == _BookingStep.driverComing) return null;
    return Marker(
      markerId: const MarkerId('user_live_marker'),
      position: _userLiveLocation,
      anchor: const Offset(0.5, 0.5),
      icon:
          _userLocationMarkerIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'You', snippet: 'Current location'),
    );
  }

  _RidePricing _ridePricingForSelection() {
    final quote = _backendQuote;
    if (quote != null && quote.rideType == _apiRideType) {
      return _RidePricing(
        baseFare: _roundToHalf(quote.baseFare),
        minimumFare: _roundToHalf(quote.minimumFare),
        recommendedFare: _roundToHalf(
          math.max(quote.minimumFare, quote.recommendedFare),
        ),
      );
    }
    final distanceKm = ((_routeDistanceMeters ?? 3000) / 1000).clamp(0.8, 60.0);
    final rideId = _selectedRideOptionId ?? 'bike';
    late final double base;
    late final double minFloor;
    late final double recommendedBoost;

    switch (rideId) {
      case 'mini':
        base = 2.8 + (distanceKm * 1.25);
        minFloor = 4.0;
        recommendedBoost = 1.0;
        break;
      case 'ac':
        base = 3.6 + (distanceKm * 1.55);
        minFloor = 5.5;
        recommendedBoost = 1.5;
        break;
      case 'bike':
      default:
        base = 1.8 + (distanceKm * 0.85);
        minFloor = 2.0;
        recommendedBoost = 0.5;
        break;
    }

    final roundedBase = _roundToHalf(base);
    final minimum = _roundToHalf(math.max(minFloor, roundedBase - 1.5));
    final recommended = _roundToHalf(
      math.max(roundedBase + recommendedBoost, minimum + 0.5),
    );
    return _RidePricing(
      baseFare: roundedBase,
      minimumFare: minimum,
      recommendedFare: recommended,
    );
  }

  double _roundToHalf(double value) => (value * 2).roundToDouble() / 2;

  String get _apiRideType => switch (_selectedRideOptionId ?? 'bike') {
    'mini' => 'mini',
    'ac' => 'ac',
    _ => 'bike',
  };

  Future<void> _loadRideQuoteForSelection() async {
    final from = _fromPlace;
    final to = _toPlace;
    final fromLat = (from?['lat'] as num?)?.toDouble();
    final fromLng = (from?['lng'] as num?)?.toDouble();
    final toLat = (to?['lat'] as num?)?.toDouble();
    final toLng = (to?['lng'] as num?)?.toDouble();
    if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
      return;
    }
    final quote = await _riderApiRepository.getRideQuote(
      pickupLat: fromLat,
      pickupLng: fromLng,
      dropoffLat: toLat,
      dropoffLng: toLng,
      rideType: _apiRideType,
    );
    if (!mounted || quote == null) return;
    setState(() {
      _backendQuote = quote;
      _selectedFare = _roundToHalf(
        math.max(quote.minimumFare, quote.recommendedFare),
      );
      if (quote.distanceText.isNotEmpty) {
        _routeDistanceText = quote.distanceText;
      }
      if (quote.durationText.isNotEmpty) {
        _rideEtaTexts = <String, String>{
          ..._rideEtaTexts,
          _selectedRideOptionId ?? 'bike': quote.durationText,
        };
      }
    });
  }

  void _startRideRequestStatusPolling() {
    _rideRequestStatusTimer?.cancel();
    _rideRequestStatusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_fetchRideRequestStatusOnce());
    });
  }

  bool _isRequestStatusExpiredOrTerminal(RideRequestStatusResult status) {
    final normalized = status.status.toLowerCase().trim();
    const terminalStates = <String>{
      'expired',
      'cancelled',
      'canceled',
      'failed',
      'rejected',
      'timed_out',
      'timeout',
      'completed',
    };
    if (terminalStates.contains(normalized)) return true;

    final expiresAt = status.expiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().toUtc().isAfter(expiresAt.toUtc());
  }

  Future<void> _resetExpiredActiveRequest({
    required String requestId,
    bool showMessage = true,
    bool cancelOnServer = true,
    String message = 'Request expired. Please request again.',
  }) async {
    _rideRequestStatusTimer?.cancel();
    _clearPendingDriverRequests();
    if (cancelOnServer) {
      await _riderApiRepository.cancelRideRequest(requestId);
    }
    if (!mounted) return;
    setState(() {
      _activeRideRequestId = null;
      _isSubmittingRideRequest = false;
      if (_bookingStep == _BookingStep.selectDriver) {
        _bookingStep = _BookingStep.chooseRide;
        _isRideBottomSheetVisible = true;
      }
    });
    if (showMessage) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _fetchRideRequestStatusOnce() async {
    final requestId = _activeRideRequestId;
    if (requestId == null) return;
    final status = await _riderApiRepository.getRideRequestStatus(requestId);
    if (!mounted || status == null) return;
    if (_isRequestStatusExpiredOrTerminal(status)) {
      final normalizedStatus = status.status.toLowerCase().trim();
      final isCancelled =
          normalizedStatus == 'cancelled' || normalizedStatus == 'canceled';
      await _resetExpiredActiveRequest(
        requestId: requestId,
        cancelOnServer: false,
        message: isCancelled
            ? 'Request cancelled.'
            : 'Request expired. Please request again.',
      );
      return;
    }
    if (status.status.toLowerCase().trim() == 'accepted' &&
        status.acceptedOffer != null) {
      _rideRequestStatusTimer?.cancel();
      _clearPendingDriverRequests();
      final acceptedOffer = status.acceptedOffer!;
      await _confirmDriverAndShowTripSheet(_DriverOffer.fromApi(acceptedOffer));
      return;
    }

    final offers = status.offers
        .where((offer) {
          final normalized = offer.status.toLowerCase().trim();
          return normalized == 'driver_accepted' ||
              normalized == 'driver_offered' ||
              normalized == 'driver_confirmed';
        })
        .toList(growable: false);
    if (offers.isEmpty) return;

    setState(() {
      final existingIds = _pendingDriverOffers
          .map((e) => e.backendOfferId)
          .whereType<String>()
          .toSet();
      for (final apiOffer in offers) {
        if (apiOffer.offerId.isEmpty ||
            existingIds.contains(apiOffer.offerId)) {
          continue;
        }
        _pendingDriverOffers.insert(
          0,
          _PendingDriverOffer(
            id: ++_driverRequestSeq,
            backendOfferId: apiOffer.offerId,
            offer: _DriverOffer.fromApi(apiOffer),
            createdAt: DateTime.now(),
            expiresAt:
                apiOffer.expiresAt ??
                DateTime.now().add(const Duration(seconds: 15)),
          ),
        );
      }
      if (_pendingDriverOffers.length > 3) {
        _pendingDriverOffers.removeRange(3, _pendingDriverOffers.length);
      }
    });
    _startDriverOfferTickerIfNeeded();
  }

  Future<void> _requestRideAndListenOffers() async {
    final wallet = ref.read(walletProvider);
    if (!wallet.isLoaded) return;
    if (wallet.balance < _selectedFare) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient wallet balance. Add money before requesting this ride.',
          ),
        ),
      );
      return;
    }
    final from = _fromPlace;
    final to = _toPlace;
    final fromLat = (from?['lat'] as num?)?.toDouble();
    final fromLng = (from?['lng'] as num?)?.toDouble();
    final toLat = (to?['lat'] as num?)?.toDouble();
    final toLng = (to?['lng'] as num?)?.toDouble();
    if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
      return;
    }
    setState(() {
      _isSubmittingRideRequest = true;
      _clearPendingDriverRequests();
    });
    final created = await _riderApiRepository.createRideRequest(
      pickupLat: fromLat,
      pickupLng: fromLng,
      dropoffLat: toLat,
      dropoffLng: toLng,
      rideType: _apiRideType,
      offeredFare: _selectedFare,
    );
    var requestResult = created;
    debugPrint(
      '[Home][RideRequest] parsed requestId=${requestResult?.requestId}, status=${requestResult?.status}',
    );
    if (requestResult != null &&
        requestResult.requestId.isNotEmpty &&
        requestResult.status == 'active_exists') {
      final existingStatus = await _riderApiRepository.getRideRequestStatus(
        requestResult.requestId,
      );
      if (!mounted) return;
      if (existingStatus != null &&
          _isRequestStatusExpiredOrTerminal(existingStatus)) {
        await _resetExpiredActiveRequest(
          requestId: requestResult.requestId,
          showMessage: false,
        );
        requestResult = await _riderApiRepository.createRideRequest(
          pickupLat: fromLat,
          pickupLng: fromLng,
          dropoffLat: toLat,
          dropoffLng: toLng,
          rideType: _apiRideType,
          offeredFare: _selectedFare,
        );
        debugPrint(
          '[Home][RideRequest][Retry] parsed requestId=${requestResult?.requestId}, status=${requestResult?.status}',
        );
      }
    }
    if (!mounted) return;
    if (requestResult == null || requestResult.requestId.isEmpty) {
      setState(() {
        _isSubmittingRideRequest = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create ride request on server.'),
        ),
      );
      return;
    }
    final requestId = requestResult.requestId;

    setState(() {
      _isSubmittingRideRequest = false;
      _bookingStep = _BookingStep.selectDriver;
      _isRideBottomSheetVisible = true;
      _activeRideRequestId = requestId;
    });
    _startRideRequestStatusPolling();
    await _fetchRideRequestStatusOnce();
  }

  Future<void> _cancelActiveRideAndExit() async {
    final rideId = _activeRideId;
    if (rideId != null) {
      await _riderApiRepository.cancelRide(rideId);
    }
    if (!mounted) return;
    _exitRideSelection();
  }

  Future<void> _cancelSearchingRequest() async {
    final requestId = _activeRideRequestId;
    _rideRequestStatusTimer?.cancel();
    if (requestId != null && requestId.isNotEmpty) {
      final cancelled = await _riderApiRepository.cancelRideRequest(requestId);
      if (!mounted) return;
      if (!cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not cancel request on server.')),
        );
        return;
      }
      await _resetExpiredActiveRequest(
        requestId: requestId,
        cancelOnServer: false,
        message: 'Request cancelled.',
      );
      return;
    }
    if (!mounted) return;
    _exitRideSelection();
  }

  void _resetSelectedFare() {
    _selectedFare = _ridePricingForSelection().recommendedFare;
  }

  void _adjustFare(bool increase) {
    final pricing = _ridePricingForSelection();
    setState(() {
      if (increase) {
        _selectedFare = _roundToHalf(_selectedFare + 0.5);
      } else {
        _selectedFare = _roundToHalf(
          math.max(pricing.minimumFare, _selectedFare - 0.5),
        );
      }
      _clearPendingDriverRequests();
    });
  }

  void _clearPendingDriverRequests() {
    _driverOfferTicker?.cancel();
    _driverOfferTicker = null;
    for (final timer in _scheduledIncomingOfferTimers) {
      timer.cancel();
    }
    _scheduledIncomingOfferTimers.clear();
    _pendingDriverOffers.clear();
  }

  void _startDriverOfferTickerIfNeeded() {
    if (_driverOfferTicker != null) return;
    _driverOfferTicker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      if (_pendingDriverOffers.isEmpty) {
        _driverOfferTicker?.cancel();
        _driverOfferTicker = null;
        return;
      }
      final now = DateTime.now();
      final before = _pendingDriverOffers.length;
      _pendingDriverOffers.removeWhere((o) => now.isAfter(o.expiresAt));
      if (_pendingDriverOffers.isEmpty &&
          _bookingStep == _BookingStep.selectDriver) {
        setState(() {});
        _driverOfferTicker?.cancel();
        _driverOfferTicker = null;
        return;
      }
      if (_pendingDriverOffers.length != before) {
        setState(() {});
        return;
      }
      if (_bookingStep == _BookingStep.selectDriver) {
        setState(() {});
      }
    });
  }

  double _pendingOfferProgress(_PendingDriverOffer pending) {
    final totalMs =
        pending.expiresAt.millisecondsSinceEpoch -
        pending.createdAt.millisecondsSinceEpoch;
    if (totalMs <= 0) return 0;
    final remainingMs =
        pending.expiresAt.millisecondsSinceEpoch -
        DateTime.now().millisecondsSinceEpoch;
    return (remainingMs / totalMs).clamp(0, 1);
  }

  void _onDriverOfferAction({required int offerId, required bool accepted}) {
    final index = _pendingDriverOffers.indexWhere((o) => o.id == offerId);
    if (index < 0) return;
    final pending = _pendingDriverOffers[index];
    final selected = pending.offer;
    setState(() {
      _pendingDriverOffers.removeWhere((o) => o.id == offerId);
    });
    unawaited(() async {
      if (accepted) {
        final wallet = ref.read(walletProvider);
        if (!wallet.isLoaded || wallet.balance < selected.offeredFare) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Wallet balance is lower than this driver fare. Add money or wait for another offer.',
              ),
            ),
          );
          return;
        }
        final backendId = pending.backendOfferId;
        DriverOfferApiData? acceptedApiOffer;
        if (backendId != null) {
          final acceptRes = await _riderApiRepository.acceptOffer(backendId);
          if (!mounted) return;
          if (acceptRes == null || acceptRes.rideId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to accept offer.')),
            );
            return;
          }
          _activeRideId = acceptRes.rideId;
          acceptedApiOffer = acceptRes.acceptedOffer;
        }
        _rideRequestStatusTimer?.cancel();
        _clearPendingDriverRequests();
        await _confirmDriverAndShowTripSheet(
          acceptedApiOffer != null
              ? _DriverOffer.fromApi(acceptedApiOffer)
              : selected,
        );
        return;
      }

      final backendId = pending.backendOfferId;
      if (backendId != null) {
        await _riderApiRepository.declineOffer(backendId);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer declined. Waiting for other drivers...'),
        ),
      );
    }());
  }

  Future<void> _confirmDriverAndShowTripSheet(_DriverOffer offer) async {
    final from = _fromPlace;
    final riderLat =
        (from?['lat'] as num?)?.toDouble() ?? _currentLocation.latitude;
    final riderLng =
        (from?['lng'] as num?)?.toDouble() ?? _currentLocation.longitude;
    final rider = LatLng(riderLat, riderLng);
    final fallbackNearbyDriver = _nearbyDriversById[offer.driver.id];
    final driver =
        offer.driver.liveLocation ??
        (fallbackNearbyDriver != null
            ? LatLng(fallbackNearbyDriver.lat, fallbackNearbyDriver.lng)
            : null);
    final distanceMeters = driver == null
        ? 0
        : _haversineDistanceMeters(rider, driver);
    final etaMinutes = driver == null
        ? 0
        : math.max(1, (distanceMeters / 260).round());
    final initialArrivalSeconds =
        offer.driver.etaToPickupSeconds ??
        (driver == null ? 0 : math.max(60, etaMinutes * 60));

    setState(() {
      _confirmedOffer = offer;
      _confirmedDriverLocation = driver;
      _confirmedRiderLocation = rider;
      _confirmedDriverDistanceMeters = distanceMeters;
      _confirmedDriverEtaText = driver == null
          ? 'Tracking driver...'
          : '$etaMinutes mins away';
      _confirmedArrivalSeconds = initialArrivalSeconds;
      _tripProgress = _TripProgress.driverComing;
      _hasChargedCompletedRide = false;
      _isDriverDetailBottomSheetCollapsed = false;
      _bookingStep = _BookingStep.driverComing;
    });

    _startDriverApproachSimulation(offer.driver.id);

    final controller = _googleMapController;
    if (controller == null) return;

    if (driver == null) {
      await controller.animateCamera(CameraUpdate.newLatLngZoom(rider, 15));
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        math.min(rider.latitude, driver.latitude),
        math.min(rider.longitude, driver.longitude),
      ),
      northeast: LatLng(
        math.max(rider.latitude, driver.latitude),
        math.max(rider.longitude, driver.longitude),
      ),
    );
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 90));
  }

  void _startDriverApproachSimulation(int driverId) {
    _driverApproachTimer?.cancel();
    _driverApproachTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      if (!mounted ||
          _bookingStep != _BookingStep.driverComing ||
          _tripProgress != _TripProgress.driverComing) {
        timer.cancel();
        return;
      }

      final rider = _confirmedRiderLocation;
      if (rider == null) {
        timer.cancel();
        return;
      }
      final latestNearby = await _riderApiRepository.getNearbyDrivers(
        lat: rider.latitude,
        lng: rider.longitude,
        radius: 5,
        rideType: _apiRideType,
      );
      if (!mounted) return;
      final latestMap = {for (final driver in latestNearby) driver.id: driver};
      final latestDriver = latestMap[driverId];
      if (latestDriver == null) {
        return;
      }
      final nextDriver = LatLng(latestDriver.lat, latestDriver.lng);
      final nextDistance = _haversineDistanceMeters(nextDriver, rider);
      final nextArrivalSeconds = math.max(0, (nextDistance / 260).round());

      setState(() {
        _nearbyDriversById = latestMap;
        _confirmedDriverLocation = nextDriver;
        _confirmedDriverDistanceMeters = nextDistance;
        _confirmedArrivalSeconds = nextArrivalSeconds;
        if (nextDistance <= 45 || nextArrivalSeconds == 0) {
          _confirmedDriverEtaText = 'Arriving now';
        } else {
          final mins = math.max(1, (nextArrivalSeconds / 60).ceil());
          _confirmedDriverEtaText = '$mins mins away';
        }
      });

      if (nextDistance <= 20) {
        timer.cancel();
      }
    });
  }

  void _markDriverReached() {
    _driverApproachTimer?.cancel();
    final rider = _confirmedRiderLocation;
    if (rider == null) return;
    setState(() {
      _tripProgress = _TripProgress.driverReached;
      _confirmedDriverLocation = rider;
      _confirmedDriverDistanceMeters = 0;
      _confirmedArrivalSeconds = 0;
      _confirmedDriverEtaText = 'Driver arrived';
    });
  }

  void _startRideProgress() {
    setState(() {
      _tripProgress = _TripProgress.rideStarted;
      _confirmedDriverDistanceMeters = 0;
      _confirmedArrivalSeconds = 0;
      _confirmedDriverEtaText = 'On the way to destination';
    });
  }

  Future<void> _completeRideProgress() async {
    final offer = _confirmedOffer;
    if (offer == null || _hasChargedCompletedRide) return;

    final charged = await ref
        .read(walletProvider.notifier)
        .chargeRide(amount: offer.offeredFare, driverName: offer.driver.name);
    if (!mounted) return;
    if (!charged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet balance is too low to complete this ride.'),
        ),
      );
      return;
    }

    final destination = _dropoffLatLng;
    setState(() {
      _tripProgress = _TripProgress.rideCompleted;
      _hasChargedCompletedRide = true;
      if (destination != null) {
        _confirmedDriverLocation = destination;
        _confirmedRiderLocation = destination;
      }
      _confirmedDriverDistanceMeters = 0;
      _confirmedArrivalSeconds = 0;
      _confirmedDriverEtaText = 'Ride completed';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallet = ref.watch(walletProvider);
    final shouldNightStyle = _shouldUseNightStyle(Theme.of(context).brightness);
    final showRideOptions =
        _selectedService == 0 &&
        _bookingStep == _BookingStep.chooseRide &&
        _fromPlace != null &&
        _toPlace != null;
    final showDriverSelection =
        _selectedService == 0 &&
        _bookingStep == _BookingStep.selectDriver &&
        _fromPlace != null &&
        _toPlace != null;
    final showRideFlowSheet = showRideOptions || showDriverSelection;
    final showDriverComing =
        _selectedService == 0 &&
        _bookingStep == _BookingStep.driverComing &&
        _confirmedOffer != null;
    final userLocationMarker = _buildUserLocationMarker();
    final mapMarkers = showDriverComing
        ? _buildDriverComingMarkers()
        : {
            ..._routeMarkers,
            ..._nearbyDriverMarkers,
            if (userLocationMarker != null) userLocationMarker,
          };
    final mapPolylines = showDriverComing
        ? _buildDriverComingPolylines()
        : _polylines;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = 70.0; // Height of bottom navigation bar
    final walletIconOffset = 15.0; // 15px above Wallet icon
    const containerHeight = 141.0;
    final hasDriverOffer = _pendingDriverOffers.isNotEmpty;

    // Calculate the position of the search container
    // It should be 15px above the Wallet icon in the bottom nav
    final searchContainerBottom =
        safeAreaBottom + bottomNavHeight + walletIconOffset;
    final showNoActiveDriversChip =
        !showRideFlowSheet &&
        !showDriverComing &&
        _selectedService == 0 &&
        _nearbyDriverMarkers.isEmpty;

    return PopScope(
      canPop: _bookingStep == _BookingStep.main,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleSystemBack();
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawer(),
        body: Stack(
          children: [
            // Map covering the whole screen
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 15,
              ),
              style: shouldNightStyle ? _nightMapStyle : null,
              onMapCreated: (controller) {
                _googleMapController = controller;
                final initialTarget = _pendingInitialCameraTarget;
                if (initialTarget != null) {
                  _pendingInitialCameraTarget = null;
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(initialTarget, 15),
                  );
                }
                final bounds = _pendingRouteBounds;
                if (bounds != null) {
                  _pendingRouteBounds = null;
                  controller.animateCamera(
                    CameraUpdate.newLatLngBounds(bounds, 64),
                  );
                }
              },
              markers: mapMarkers,
              polylines: mapPolylines,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
            ),

            // Top navigation bar with 15px padding
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTopNavigationBar(
                      isDark,
                      inBookingFlow: showRideOptions || showDriverSelection,
                    ),
                    if (!showDriverComing &&
                        _fromPlace != null &&
                        _toPlace != null) ...[
                      const SizedBox(height: 12),
                      _buildSelectedLocationsBar(isDark),
                    ],
                  ],
                ),
              ),
            ),

            // Rental button and location target icon row - positioned 15px above search container
            if (!showRideOptions && !showDriverSelection && !showDriverComing)
              Positioned(
                bottom: searchContainerBottom + containerHeight + 15,
                left: 15,
                right: 15,
                child: _buildRentalAndLocationRow(isDark),
              ),

            if (showNoActiveDriversChip)
              Positioned(
                bottom: searchContainerBottom + containerHeight + 80,
                left: 15,
                child: _buildNoActiveDriversChip(isDark),
              ),

            // Main state search container
            if (!showDriverComing && !showRideFlowSheet)
              Positioned(
                bottom: searchContainerBottom,
                left: 15,
                right: 15,
                child: _buildSearchContainer(
                  isDark,
                  wallet,
                  showRideOptions: false,
                  showDriverSelection: false,
                ),
              ),

            if (showRideFlowSheet && _isRideBottomSheetVisible)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildRideFlowBottomSheet(
                  isDark,
                  wallet,
                  showRideOptions: showRideOptions,
                  showDriverSelection: showDriverSelection,
                ),
              ),

            if (showRideFlowSheet && !_isRideBottomSheetVisible)
              Positioned(
                right: 16,
                bottom: safeAreaBottom + 16,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isRideBottomSheetVisible = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEDAE10),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_up),
                  label: const Text(
                    'Show ride',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            if (showDriverSelection && hasDriverOffer)
              Positioned(
                left: 20,
                right: 20,
                bottom: (_isRideBottomSheetVisible ? 270 : 96) + safeAreaBottom,
                child: _buildDriverOfferStack(isDark),
              ),

            if (showDriverComing && !_isDriverDetailBottomSheetCollapsed)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildDriverComingBottomSheet(isDark),
              ),

            if (showDriverComing && _isDriverDetailBottomSheetCollapsed)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildCollapsedDriverComingSheet(isDark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar(bool isDark, {required bool inBookingFlow}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIconButton(
          icon: inBookingFlow ? Icons.arrow_back : Icons.menu,
          onTap: _goBackInBookingFlow,
          isDark: isDark,
        ),

        if (!inBookingFlow)
          Row(
            children: [
              _buildIconButton(
                icon: Icons.search,
                onTap: () {},
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.notifications_outlined,
                onTap: () {},
                isDark: isDark,
              ),
            ],
          )
        else
          const SizedBox(width: 34),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1B1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF414141)),
      ),
    );
  }

  Widget _buildRentalAndLocationRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Rental button
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDAE10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'Rental',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),

        // Location target icon
        GestureDetector(
          onTap: () {
            unawaited(_recenterToCurrentLocation());
          },
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF35383F) : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: CustomPaint(
              size: const Size(34, 34),
              painter: TargetIconPainter(
                color: isDark
                    ? const Color(0xFFD0D0D0)
                    : const Color(0xFF5A5A5A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoActiveDriversChip(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xE61F212A)
            : const Color.fromRGBO(255, 255, 255, 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDAE10), width: 1),
      ),
      child: Text(
        'No active drivers nearby',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFF1F1F1) : const Color(0xFF2A2A2A),
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildSearchContainer(
    bool isDark,
    WalletState wallet, {
    required bool showRideOptions,
    required bool showDriverSelection,
  }) {
    final pricing = _ridePricingForSelection();
    if (showRideOptions && _selectedFare <= 0) {
      _selectedFare = pricing.recommendedFare;
    }
    final selectedRide = _selectedRideOptionId ?? 'bike';
    final selectedRideLabel = switch (selectedRide) {
      'mini' => 'Mini car',
      'ac' => 'AC Car',
      _ => 'Bike',
    };
    return Container(
      constraints: BoxConstraints(
        minHeight: showRideOptions ? 320 : (showDriverSelection ? 185 : 141),
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F212A) : const Color(0xFFFFFBE7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF3BD06), width: 1),
      ),
      padding: const EdgeInsets.only(top: 13, bottom: 11, left: 14, right: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!showRideOptions && !showDriverSelection) ...[
            // Search bar
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF35383F)
                    : const Color(0xFFFFFBE7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF3BD06), width: 1),
              ),
              child: GestureDetector(
                onTap: () {
                  _openAddressSelectionSheet();
                },
                child: AbsorbPointer(
                  child: TextField(
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFD0D0D0)
                          : const Color(0xFFA0A0A0),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 23 / 16,
                      fontFamily: 'Poppins',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Where would you go?',
                      hintStyle: TextStyle(
                        color: isDark
                            ? const Color(0xFFD0D0D0)
                            : const Color(0xFFA0A0A0),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 23 / 16,
                        fontFamily: 'Poppins',
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 24,
                        color: isDark
                            ? const Color(0xFFD0D0D0)
                            : const Color(0xFFA0A0A0),
                      ),
                      suffixIcon: Icon(
                        Icons.favorite,
                        size: 24,
                        color: isDark
                            ? const Color(0xFFD0D0D0)
                            : const Color(0xFFA0A0A0),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 13),

            // Transport/Delivery switch
            _buildServiceSwitch(isDark),
          ],
          if (showRideOptions) ...[
            Text(
              'Choose ride',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            _buildRideOptionsRow(isDark),
            const SizedBox(height: 12),
            _buildFareSelector(isDark, pricing),
            const SizedBox(height: 10),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _isSubmittingRideRequest
                    ? null
                    : _requestRideAndListenOffers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDAE10),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isSubmittingRideRequest
                      ? 'Requesting...'
                      : 'Request ride at \$${_selectedFare.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
          if (showDriverSelection) ...[
            Text(
              'Selecting driver',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$selectedRideLabel • Your fare: \$${_selectedFare.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFFD0D0D0)
                    : const Color(0xFF5A5A5A),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  _rideRequestStatusTimer?.cancel();
                  setState(() {
                    _bookingStep = _BookingStep.chooseRide;
                    _activeRideRequestId = null;
                    _clearPendingDriverRequests();
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEDAE10)),
                  foregroundColor: const Color(0xFFEDAE10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Offer different fare',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRideOptionsRow(bool isDark) {
    final options = <({String id, String label, IconData icon})>[
      (id: 'bike', label: 'Bike', icon: Icons.directions_bike),
      (id: 'mini', label: 'Mini car', icon: Icons.directions_car),
      (id: 'ac', label: 'AC Car', icon: Icons.air),
    ];

    final selected = _selectedRideOptionId ?? options.first.id;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options
            .map((opt) {
              final isSelected = selected == opt.id;
              final eta = _rideEtaTexts[opt.id];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRideOptionId = opt.id;
                      _resetSelectedFare();
                      _backendQuote = null;
                      _clearPendingDriverRequests();
                    });
                    _rideRequestStatusTimer?.cancel();
                    unawaited(_loadRideQuoteForSelection());
                    final from = _fromPlace;
                    final fromLat = (from?['lat'] as num?)?.toDouble();
                    final fromLng = (from?['lng'] as num?)?.toDouble();
                    if (fromLat != null && fromLng != null) {
                      unawaited(
                        _syncLocationAndNearbyDrivers(
                          LatLng(fromLat, fromLng),
                          rideType: _apiRideType,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 108,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEDAE10)
                          : (isDark ? const Color(0xFF35383F) : Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFEDAE10)
                            : const Color(0xFFF3BD06),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          opt.icon,
                          size: 26,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.white
                                    : const Color(0xFF2A2A2A)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          opt.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white
                                      : const Color(0xFF2A2A2A)),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (eta != null && eta.isNotEmpty) ? eta : '...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? const Color(0xFFD0D0D0)
                                      : const Color(0xFF5A5A5A)),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }

  Widget _buildFareSelector(bool isDark, _RidePricing pricing) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3BD06), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Base: \$${pricing.baseFare.toStringAsFixed(1)}  •  Recommended: \$${pricing.recommendedFare.toStringAsFixed(1)}',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF2A2A2A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Minimum fare: \$${pricing.minimumFare.toStringAsFixed(1)}',
            style: TextStyle(
              color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFareActionButton(
                icon: Icons.remove,
                onTap: () => _adjustFare(false),
                isDark: isDark,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '\$${_selectedFare.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              _buildFareActionButton(
                icon: Icons.add,
                onTap: () => _adjustFare(true),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFareActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F212A) : const Color(0xFFFFFBE7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF3BD06), width: 1),
        ),
        child: Icon(icon, color: const Color(0xFFEDAE10)),
      ),
    );
  }

  Widget _buildRideFlowBottomSheet(
    bool isDark,
    WalletState wallet, {
    required bool showRideOptions,
    required bool showDriverSelection,
  }) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final pricing = _ridePricingForSelection();
    if (showRideOptions && _selectedFare <= 0) {
      _selectedFare = pricing.recommendedFare;
    }
    final selectedRide = _selectedRideOptionId ?? 'bike';
    final selectedRideLabel = switch (selectedRide) {
      'mini' => 'Mini car',
      'ac' => 'AC Car',
      _ => 'Bike',
    };
    final isSearchingDrivers =
        showDriverSelection &&
        _activeRideRequestId != null &&
        _pendingDriverOffers.isEmpty;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(14, 10, 14, 12 + bottomPadding),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F212A) : const Color(0xFFFFFBE7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(color: const Color(0xFFF3BD06), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 56,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF6B6F78)
                        : const Color(0xFFB8B8B8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isRideBottomSheetVisible = false;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: isDark ? Colors.white : const Color(0xFF414141),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (showRideOptions) ...[
              Text(
                'Choose ride',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              _buildRideOptionsRow(isDark),
              const SizedBox(height: 12),
              _buildFareSelector(isDark, pricing),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed:
                      _isSubmittingRideRequest ||
                          !wallet.isLoaded ||
                          wallet.balance < _selectedFare
                      ? null
                      : _requestRideAndListenOffers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEDAE10),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isSubmittingRideRequest
                        ? 'Requesting...'
                        : !wallet.isLoaded
                        ? 'Loading wallet...'
                        : wallet.balance < _selectedFare
                        ? 'Insufficient wallet balance'
                        : 'Request ride at \$${_selectedFare.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (wallet.isLoaded) ...[
                const SizedBox(height: 8),
                Text(
                  'Wallet balance: \$${wallet.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFD0D0D0)
                        : const Color(0xFF5A5A5A),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ],
            if (showDriverSelection) ...[
              Text(
                isSearchingDrivers
                    ? 'Searching for driver'
                    : 'Selecting driver',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSearchingDrivers
                    ? '$selectedRideLabel • Request sent. Waiting for driver offers...'
                    : '$selectedRideLabel • Your fare: \$${_selectedFare.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFD0D0D0)
                      : const Color(0xFF5A5A5A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              if (isSearchingDrivers) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    minHeight: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFEDAE10),
                    ),
                    backgroundColor: Color(0xFFEAEAEA),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () {
                    if (isSearchingDrivers) {
                      unawaited(_cancelSearchingRequest());
                      return;
                    }
                    _rideRequestStatusTimer?.cancel();
                    setState(() {
                      _bookingStep = _BookingStep.chooseRide;
                      _isRideBottomSheetVisible = true;
                      _activeRideRequestId = null;
                      _clearPendingDriverRequests();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEDAE10)),
                    foregroundColor: const Color(0xFFEDAE10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isSearchingDrivers
                        ? 'Cancel request'
                        : 'Offer different fare',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDriverOfferStack(bool isDark) {
    if (_pendingDriverOffers.isEmpty) return const SizedBox.shrink();
    final visible = _pendingDriverOffers.take(3).toList(growable: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: visible
          .map(
            (pending) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildDriverOfferCard(isDark, pending),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildDriverOfferCard(bool isDark, _PendingDriverOffer pending) {
    final offer = pending.offer;
    final progress = _pendingOfferProgress(pending);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F212A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3BD06), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver offer #${pending.id}',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${offer.driver.name} • ${offer.driver.car} • ★ ${offer.driver.rating.toStringAsFixed(1)}',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFD0D0D0)
                    : const Color(0xFF5A5A5A),
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Driver fare: \$${offer.offeredFare.toStringAsFixed(1)}',
              style: const TextStyle(
                color: Color(0xFFEDAE10),
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: progress,
                backgroundColor: isDark
                    ? const Color(0xFF35383F)
                    : const Color(0xFFEFEFEF),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFEDAE10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _onDriverOfferAction(
                      offerId: pending.id,
                      accepted: false,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD93025)),
                      foregroundColor: const Color(0xFFD93025),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onDriverOfferAction(
                      offerId: pending.id,
                      accepted: true,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34A853),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Set<Marker> _buildDriverComingMarkers() {
    final offer = _confirmedOffer;
    final driver = _confirmedDriverLocation;
    final rider = _confirmedRiderLocation;
    if (offer == null || driver == null || rider == null) {
      return const <Marker>{};
    }

    final destination = _dropoffLatLng;
    final target = _isTripInProgress && destination != null
        ? destination
        : rider;
    final targetSnippet = _isTripInProgress ? 'Ride target' : 'Pickup point';
    final driverSnippet = _tripProgress == _TripProgress.rideCompleted
        ? 'Trip completed'
        : _tripProgress == _TripProgress.rideStarted
        ? 'Heading to destination'
        : '${_formatDistance(_confirmedDriverDistanceMeters)} • $_confirmedDriverEtaText';

    return {
      Marker(
        markerId: const MarkerId('rider_car_marker'),
        position: target,
        icon:
            _userLocationMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.5),
        infoWindow: InfoWindow(title: 'You', snippet: targetSnippet),
      ),
      Marker(
        markerId: const MarkerId('driver_car_marker'),
        position: driver,
        icon:
            _nearbyCarMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: offer.driver.name,
          snippet: driverSnippet,
        ),
      ),
      if (_isTripInProgress && rider != target)
        Marker(
          markerId: const MarkerId('pickup_marker'),
          position: rider,
          infoWindow: const InfoWindow(
            title: 'Pickup point',
            snippet: 'Ride started here',
          ),
        ),
    };
  }

  Set<Polyline> _buildDriverComingPolylines() {
    final driver = _confirmedDriverLocation;
    final rider = _confirmedRiderLocation;
    if (driver == null || rider == null) return const <Polyline>{};

    final destination = _dropoffLatLng;
    if (_tripProgress == _TripProgress.rideCompleted) {
      return const <Polyline>{};
    }

    final polylinePoints =
        _tripProgress == _TripProgress.rideStarted && destination != null
        ? <LatLng>[driver, destination]
        : <LatLng>[driver, rider];

    return {
      Polyline(
        polylineId: const PolylineId('driver_to_rider'),
        points: polylinePoints,
        color: const Color(0xFFF3BD06),
        width: 6,
      ),
    };
  }

  Widget _buildDriverComingBottomSheet(bool isDark) {
    final offer = _confirmedOffer;
    if (offer == null) return const SizedBox.shrink();
    final wallet = ref.watch(walletProvider);
    final paymentAmount = offer.offeredFare;
    final distanceText = _formatDistance(_confirmedDriverDistanceMeters);
    final arrivalText = _formatArrivalClock(_confirmedArrivalSeconds);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final panelColor = isDark
        ? const Color(0xFF343742)
        : const Color(0xFFF2F2F2);
    final textColor = isDark ? Colors.white : const Color(0xFF2A2A2A);
    final subtitleColor = isDark
        ? const Color(0xFFC7C7C7)
        : const Color(0xFF6B6B6B);
    final headline = switch (_tripProgress) {
      _TripProgress.driverComing =>
        _confirmedArrivalSeconds > 0
            ? 'Your driver is coming in $arrivalText'
            : 'Your driver has arrived',
      _TripProgress.driverReached => 'Your driver has arrived',
      _TripProgress.rideStarted => 'Ride started',
      _TripProgress.rideCompleted => 'Ride completed',
    };
    final statusLine = switch (_tripProgress) {
      _TripProgress.driverComing => '$distanceText ($_confirmedDriverEtaText)',
      _TripProgress.driverReached => 'Driver reached pickup point',
      _TripProgress.rideStarted => 'Heading to your destination',
      _TripProgress.rideCompleted => 'Fare deducted from wallet',
    };
    final primaryActionLabel = switch (_tripProgress) {
      _TripProgress.driverComing => 'Mark Driver Reached',
      _TripProgress.driverReached => 'Start Ride',
      _TripProgress.rideStarted => 'Complete Ride',
      _TripProgress.rideCompleted => 'Done',
    };
    final canCompleteRide = wallet.isLoaded && wallet.balance >= paymentAmount;

    return Container(
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(14, 10, 14, 16 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF9A9A9A)
                      : const Color(0xFFB0B0B0),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDriverDetailBottomSheetCollapsed = true;
                  });
                },
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF858585)
                      : const Color(0xFF707070),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              headline,
              style: TextStyle(
                color: textColor,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 31 / 2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF777B86) : const Color(0xFFD4D4D4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E6E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF5A5A5A),
                  size: 34,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.driver.name,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 30 / 2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      statusLine,
                      style: TextStyle(
                        color: subtitleColor,
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '★ ${offer.driver.rating.toStringAsFixed(1)} (531 reviews)',
                      style: TextStyle(
                        color: subtitleColor,
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.directions_car,
                color: Color(0xFFC91D3A),
                size: 42,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF777B86) : const Color(0xFFD4D4D4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Wallet payment',
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 31 / 2,
                ),
              ),
              const Spacer(),
              Text(
                '\$${paymentAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFFE5E1CF) : const Color(0xFFEAE6D3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFF3BD06), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDAE10),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'WALLET',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.isLoaded
                          ? 'Balance: \$${wallet.balance.toStringAsFixed(2)}'
                          : 'Loading wallet...',
                      style: TextStyle(
                        color: Color(0xFF3E3E3E),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _tripProgress == _TripProgress.rideCompleted
                          ? 'Ride fare paid'
                          : canCompleteRide
                          ? 'Enough balance for this ride'
                          : 'Not enough balance to complete',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF888888)
                            : const Color(0xFF8E8E8E),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildRoundActionButton(
                icon: Icons.call,
                isDark: isDark,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _buildRoundActionButton(
                icon: Icons.chat_bubble,
                isDark: isDark,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_tripProgress == _TripProgress.driverComing) {
                        _markDriverReached();
                        return;
                      }
                      if (_tripProgress == _TripProgress.driverReached) {
                        _startRideProgress();
                        return;
                      }
                      if (_tripProgress == _TripProgress.rideStarted) {
                        unawaited(_completeRideProgress());
                        return;
                      }
                      _exitRideSelection();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3BD06),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      primaryActionLabel,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_tripProgress != _TripProgress.rideCompleted) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  unawaited(_cancelActiveRideAndExit());
                },
                child: const Text(
                  'Cancel Ride',
                  style: TextStyle(
                    color: Color(0xFFD93025),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapsedDriverComingSheet(bool isDark) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final panelColor = isDark
        ? const Color(0xFF343742)
        : const Color(0xFFF2F2F2);
    final textColor = isDark ? Colors.white : const Color(0xFF2A2A2A);
    final arrivalText = _formatArrivalClock(_confirmedArrivalSeconds);
    final collapsedText = switch (_tripProgress) {
      _TripProgress.driverComing =>
        _confirmedArrivalSeconds > 0
            ? 'Driver coming in $arrivalText'
            : 'Driver arrived',
      _TripProgress.driverReached => 'Driver reached pickup',
      _TripProgress.rideStarted => 'Ride in progress',
      _TripProgress.rideCompleted => 'Ride completed',
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(14, 10, 14, 12 + bottomPadding),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isDriverDetailBottomSheetCollapsed = false;
                });
              },
              child: Icon(
                Icons.keyboard_arrow_up,
                color: isDark ? Colors.white : const Color(0xFF414141),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                collapsedText,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              onPressed: _exitRideSelection,
              icon: Icon(
                Icons.close,
                color: isDark
                    ? const Color(0xFF858585)
                    : const Color(0xFF707070),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundActionButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(27),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF3BD06), width: 1.4),
          color: isDark ? const Color(0xFF343742) : const Color(0xFFF2F2F2),
        ),
        child: Icon(icon, color: const Color(0xFFF3BD06), size: 22),
      ),
    );
  }

  Widget _buildSelectedLocationsBar(bool isDark) {
    final fromName = (_fromPlace?['name'] as String?) ?? '';
    final toName = (_toPlace?['name'] as String?) ?? '';
    final distanceText = _routeDistanceText;

    return GestureDetector(
      onTap: _openAddressSelectionSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F212A) : const Color(0xFFFFFBE7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF3BD06), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 16,
                        color: isDark
                            ? const Color(0xFFD0D0D0)
                            : const Color(0xFF5A5A5A),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fromName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF2A2A2A),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: isDark
                            ? const Color(0xFFD0D0D0)
                            : const Color(0xFF5A5A5A),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          toName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF2A2A2A),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (distanceText != null && distanceText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.route,
                          size: 16,
                          color: isDark
                              ? const Color(0xFFD0D0D0)
                              : const Color(0xFF5A5A5A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            distanceText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF2A2A2A),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.edit,
              size: 18,
              color: isDark ? Colors.white : const Color(0xFF2A2A2A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSwitch(bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : const Color(0xFFFFFBE7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF3BD06), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedService = 0;
                });
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: _selectedService == 0
                      ? const Color(0xFFEDAE10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Transport',
                    style: TextStyle(
                      color: _selectedService == 0
                          ? Colors.white
                          : const Color(0xFF414141),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedService = 1;
                });
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: _selectedService == 1
                      ? const Color(0xFFEDAE10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Delivery',
                    style: TextStyle(
                      color: _selectedService == 1
                          ? Colors.white
                          : const Color(0xFF414141),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RidePricing {
  const _RidePricing({
    required this.baseFare,
    required this.minimumFare,
    required this.recommendedFare,
  });

  final double baseFare;
  final double minimumFare;
  final double recommendedFare;
}

class _DriverProfile {
  const _DriverProfile({
    required this.id,
    required this.name,
    required this.car,
    required this.rating,
    this.phone,
    this.liveLocation,
    this.etaToPickupSeconds,
  });

  final int id;
  final String name;
  final String car;
  final double rating;
  final String? phone;
  final LatLng? liveLocation;
  final int? etaToPickupSeconds;
}

class _DriverOffer {
  const _DriverOffer({required this.driver, required this.offeredFare});

  final _DriverProfile driver;
  final double offeredFare;

  factory _DriverOffer.fromApi(DriverOfferApiData apiOffer) {
    return _DriverOffer(
      driver: _DriverProfile(
        id: apiOffer.driverId,
        name: apiOffer.driverName,
        car: apiOffer.vehicleName,
        rating: apiOffer.rating,
        phone: apiOffer.driverPhone,
        liveLocation: apiOffer.driverLat != null && apiOffer.driverLng != null
            ? LatLng(apiOffer.driverLat!, apiOffer.driverLng!)
            : null,
        etaToPickupSeconds: apiOffer.etaToPickupSeconds,
      ),
      offeredFare: apiOffer.driverFare,
    );
  }
}

class _PendingDriverOffer {
  const _PendingDriverOffer({
    required this.id,
    this.backendOfferId,
    required this.offer,
    required this.createdAt,
    required this.expiresAt,
  });

  final int id;
  final String? backendOfferId;
  final _DriverOffer offer;
  final DateTime createdAt;
  final DateTime expiresAt;
}

class TargetIconPainter extends CustomPainter {
  final Color color;

  TargetIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2 - 4;

    // Draw outer circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Draw crosshair lines
    final lineLength = radius * 0.6;

    // Horizontal line
    canvas.drawLine(
      Offset(centerX - lineLength, centerY),
      Offset(centerX + lineLength, centerY),
      paint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(centerX, centerY - lineLength),
      Offset(centerX, centerY + lineLength),
      paint,
    );

    // Draw center diamond
    final diamondSize = 3.0;
    final diamondPath = ui.Path();
    diamondPath.moveTo(centerX, centerY - diamondSize);
    diamondPath.lineTo(centerX + diamondSize, centerY);
    diamondPath.lineTo(centerX, centerY + diamondSize);
    diamondPath.lineTo(centerX - diamondSize, centerY);
    diamondPath.close();

    final diamondPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(diamondPath, diamondPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
