import 'dart:async';
import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:draaxi/src/features/home/google_places_service.dart';
import 'package:draaxi/src/features/home/recent_places_store.dart';
import 'package:flutter/material.dart';

class AddressSelectionSheet extends StatefulWidget {
  const AddressSelectionSheet({
    super.key,
    this.initialFromPlace,
    this.initialToPlace,
    this.onConfirm,
  });

  final Map<String, dynamic>? initialFromPlace;
  final Map<String, dynamic>? initialToPlace;
  final void Function(Map<String, dynamic> from, Map<String, dynamic> to)?
  onConfirm;

  @override
  State<AddressSelectionSheet> createState() => _AddressSelectionSheetState();
}

class _AddressSelectionSheetState extends State<AddressSelectionSheet> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  Map<String, dynamic>? _selectedFromPlace;
  Map<String, dynamic>? _selectedToPlace;

  List<Map<String, dynamic>> _recentPlaces = const [];

  @override
  void initState() {
    super.initState();
    _selectedFromPlace = widget.initialFromPlace;
    _selectedToPlace = widget.initialToPlace;
    if (_selectedFromPlace != null) {
      _fromController.text = (_selectedFromPlace?['name'] as String?) ?? '';
    }
    if (_selectedToPlace != null) {
      _toController.text = (_selectedToPlace?['name'] as String?) ?? '';
    }
    unawaited(_loadRecentPlaces());
  }

  Future<void> _loadRecentPlaces() async {
    final places = await RecentPlacesStore.load();
    if (!mounted) return;
    setState(() {
      _recentPlaces = places;
    });
  }

  Future<void> _addRecentPlace(Map<String, dynamic> place) async {
    final updated = await RecentPlacesStore.add(place);
    if (!mounted) return;
    setState(() {
      _recentPlaces = updated;
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _selectPlace(Map<String, dynamic> place, {required bool isFrom}) {
    setState(() {
      if (isFrom) {
        _selectedFromPlace = place;
        _fromController.text = place['name'] as String;
      } else {
        _selectedToPlace = place;
        _toController.text = place['name'] as String;
      }
    });
    unawaited(_addRecentPlace(place));
  }

  Future<void> _selectCurrentLocation({required bool isFrom}) async {
    setState(() {
      final place = <String, dynamic>{
        'name': 'Current location',
        'address': 'Use device GPS',
        'distance': '0km',
        'lat': null,
        'lng': null,
        'isCurrent': true,
      };

      if (isFrom) {
        _selectedFromPlace = place;
        _fromController.text = 'Current location';
      } else {
        _selectedToPlace = place;
        _toController.text = 'Current location';
      }
    });

    final latLng = await DeviceLocationService.getCurrentLatLng();
    if (!mounted || latLng == null) return;

    setState(() {
      if (isFrom) {
        _selectedFromPlace = {
          ...?_selectedFromPlace,
          'lat': latLng.latitude,
          'lng': latLng.longitude,
        };
      } else {
        _selectedToPlace = {
          ...?_selectedToPlace,
          'lat': latLng.latitude,
          'lng': latLng.longitude,
        };
      }
    });

    final updatedPlace = <String, dynamic>{
      'name': 'Current location',
      'address': 'Use device GPS',
      'lat': latLng.latitude,
      'lng': latLng.longitude,
      'isCurrent': true,
    };
    unawaited(_addRecentPlace(updatedPlace));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final hasSelections =
        _selectedFromPlace != null && _selectedToPlace != null;

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle and Close button row
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Handle
                Expanded(
                  child: Center(
                    child: Container(
                      width: 134,
                      height: 1,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(0.5),
                      ),
                    ),
                  ),
                ),
                // Close button
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'Select address',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF2A2A2A),
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 20),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0x4DDDDDDD) : const Color(0xFFDDDDDD),
          ),

          Expanded(
            child: hasSelections
                ? _buildConfirmationView(isDark)
                : _buildSelectionView(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionView(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // From address field
          _buildAddressField(
            controller: _fromController,
            hint: 'From',
            icon: Icons.my_location,
            isDark: isDark,
            isFrom: true,
          ),

          const SizedBox(height: 16),

          // To address field
          _buildAddressField(
            controller: _toController,
            hint: 'To',
            icon: Icons.location_on,
            isDark: isDark,
            isFrom: false,
          ),

          const SizedBox(height: 20),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0x4DDDDDDD) : const Color(0xFFDDDDDD),
          ),

          const SizedBox(height: 20),

          // Recent Places section
          if (_recentPlaces.isNotEmpty) ...[
            Text(
              'Recent places',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            ..._recentPlaces.map(
              (place) => _buildRecentPlaceCard(place, isDark),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required bool isFrom,
  }) {
    return GestureDetector(
      onTap: () {
        // Show location picker or search
        _showLocationPicker(isFrom: isFrom, isDark: isDark);
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFB8B8B8), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Custom target icon for "From" field
            if (isFrom)
              CustomPaint(
                size: const Size(24, 24),
                painter: TargetIconFieldPainter(
                  color: isDark
                      ? const Color(0xFFD0D0D0)
                      : const Color(0xFF5A5A5A),
                ),
              )
            else
              Icon(
                icon,
                size: 24,
                color: isDark
                    ? const Color(0xFFD0D0D0)
                    : const Color(0xFF5A5A5A),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: false,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFD0D0D0)
                        : const Color(0xFF5A5A5A),
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker({required bool isFrom, required bool isDark}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PlacesSearchBottomSheet(
        isFrom: isFrom,
        isDark: isDark,
        recentPlaces: _recentPlaces,
        onSelectCurrentLocation: () {
          Navigator.pop(context);
          unawaited(_selectCurrentLocation(isFrom: isFrom));
        },
        onSelectPlace: (place) {
          Navigator.pop(context);
          _selectPlace(place, isFrom: isFrom);
        },
      ),
    );
  }

  Widget _buildRecentPlaceCard(Map<String, dynamic> place, bool isDark) {
    final distance = place['distance'] as String?;
    return GestureDetector(
      onTap: () {
        if (_selectedFromPlace == null) {
          _selectPlace(place, isFrom: true);
        } else if (_selectedToPlace == null) {
          _selectPlace(place, isFrom: false);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              size: 24,
              color: isDark ? Colors.white : const Color(0xFF5A5A5A),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place['name'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place['address'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? const Color(0xFFD0D0D0)
                          : const Color(0xFF5A5A5A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            if (distance != null)
              Text(
                distance,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                  fontFamily: 'Poppins',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationView(bool isDark) {
    final fromIsCurrent = _selectedFromPlace?['isCurrent'] == true;
    final toIsCurrent = _selectedToPlace?['isCurrent'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // From location
          GestureDetector(
            onTap: () => _showLocationPicker(isFrom: true, isDark: isDark),
            child: _buildLocationRow(
              place: _selectedFromPlace!,
              isDark: isDark,
              isCurrent: fromIsCurrent,
              isRed: fromIsCurrent,
            ),
          ),

          const SizedBox(height: 20),

          // Dotted line connecting the two locations
          CustomPaint(
            size: const Size(double.infinity, 40),
            painter: DottedLinePainter(color: const Color(0xFFFEC400)),
          ),

          const SizedBox(height: 20),

          // To location
          GestureDetector(
            onTap: () => _showLocationPicker(isFrom: false, isDark: isDark),
            child: _buildLocationRow(
              place: _selectedToPlace!,
              isDark: isDark,
              isCurrent: toIsCurrent,
              isRed: toIsCurrent,
            ),
          ),

          const SizedBox(height: 40),

          // Confirm Location button
          PrimaryButton(
            text: 'Confirm Location',
            onPressed: () {
              final from = _selectedFromPlace;
              final to = _selectedToPlace;
              if (from == null || to == null) return;
              widget.onConfirm?.call(from, to);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required Map<String, dynamic> place,
    required bool isDark,
    required bool isCurrent,
    required bool isRed,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pin icon
        SizedBox(
          width: 30,
          height: 40,
          child: CustomPaint(
            size: const Size(20, 30),
            painter: PinPainter(color: isRed ? Colors.red : Colors.amber),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place['name'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                place['address'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? const Color(0xFFD0D0D0)
                      : const Color(0xFF5A5A5A),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        if (!isCurrent && place['distance'] != null)
          Text(
            place['distance'] as String,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF2A2A2A),
              fontFamily: 'Poppins',
            ),
          ),
      ],
    );
  }
}

class _PlacesSearchBottomSheet extends StatefulWidget {
  const _PlacesSearchBottomSheet({
    required this.isFrom,
    required this.isDark,
    required this.recentPlaces,
    required this.onSelectCurrentLocation,
    required this.onSelectPlace,
  });

  final bool isFrom;
  final bool isDark;
  final List<Map<String, dynamic>> recentPlaces;
  final VoidCallback onSelectCurrentLocation;
  final void Function(Map<String, dynamic> place) onSelectPlace;

  @override
  State<_PlacesSearchBottomSheet> createState() =>
      _PlacesSearchBottomSheetState();
}

class _PlacesSearchBottomSheetState extends State<_PlacesSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final String _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  Timer? _debounce;

  late final Future<GooglePlacesService> _serviceFuture =
      GooglePlacesService.create();

  List<PlacePrediction> _predictions = const [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController
      ..removeListener(_onQueryChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final query = _searchController.text.trim();
      if (!mounted) return;
      if (query.isEmpty) {
        setState(() => _predictions = const []);
        return;
      }

      setState(() => _isLoading = true);
      final service = await _serviceFuture;
      final results = await service.autocomplete(
        input: query,
        sessionToken: _sessionToken,
      );
      if (!mounted) return;
      setState(() {
        _predictions = results;
        _isLoading = false;
      });
    });
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    setState(() => _isLoading = true);
    final service = await _serviceFuture;
    final details = await service.placeDetails(
      placeId: prediction.placeId,
      sessionToken: _sessionToken,
    );
    if (!mounted) return;

    setState(() => _isLoading = false);
    if (details == null) return;

    widget.onSelectPlace({
      'placeId': details.placeId,
      'name': details.name.isEmpty ? prediction.mainText : details.name,
      'address': details.formattedAddress,
      'lat': details.lat,
      'lng': details.lng,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final query = _searchController.text.trim();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 134,
              height: 1,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : const Color(0xFF141414),
                borderRadius: BorderRadius.circular(0.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                hintText: widget.isFrom ? 'From' : 'To',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFD0D0D0)
                      : const Color(0xFF5A5A5A),
                  fontFamily: 'Poppins',
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark
                      ? const Color(0xFFD0D0D0)
                      : const Color(0xFF5A5A5A),
                ),
                suffixIcon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _predictions = const []);
                              },
                              icon: Icon(
                                Icons.close,
                                color: isDark
                                    ? const Color(0xFFD0D0D0)
                                    : const Color(0xFF5A5A5A),
                              ),
                            )),
                filled: true,
                fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFB8B8B8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFB8B8B8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFFEC400)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                ListTile(
                  leading: const Icon(Icons.my_location, color: Colors.amber),
                  title: Text(
                    'Current location',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  subtitle: Text(
                    'Use device GPS',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFD0D0D0)
                          : const Color(0xFF5A5A5A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  onTap: widget.onSelectCurrentLocation,
                ),
                if (query.isEmpty) ...[
                  const SizedBox(height: 8),
                  ...widget.recentPlaces.map(
                    (place) => ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.amber,
                      ),
                      title: Text(
                        place['name'] as String,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2A2A2A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      subtitle: Text(
                        place['address'] as String,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFD0D0D0)
                              : const Color(0xFF5A5A5A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      trailing: place['distance'] == null
                          ? null
                          : Text(
                              place['distance'] as String,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF2A2A2A),
                                fontFamily: 'Poppins',
                              ),
                            ),
                      onTap: () => widget.onSelectPlace(place),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  ..._predictions.map(
                    (p) => ListTile(
                      leading: const Icon(Icons.place, color: Colors.amber),
                      title: Text(
                        p.mainText.isEmpty ? p.description : p.mainText,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2A2A2A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      subtitle: p.secondaryText.isEmpty
                          ? null
                          : Text(
                              p.secondaryText,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFD0D0D0)
                                    : const Color(0xFF5A5A5A),
                                fontFamily: 'Poppins',
                              ),
                            ),
                      onTap: () => _selectPrediction(p),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashWidth = 5.0;
    final dashSpace = 3.0;
    double startX = size.width / 2;
    double startY = 0;
    double endY = size.height;

    while (startY < endY) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PinPainter extends CustomPainter {
  final Color color;

  PinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Draw teardrop shape (pin)
    final centerX = size.width / 2;
    final bottomY = size.height;

    // Top circle part
    final circleRadius = size.width / 2;
    final circleCenterY = circleRadius;

    path.addArc(
      Rect.fromCircle(
        center: Offset(centerX, circleCenterY),
        radius: circleRadius,
      ),
      -3.14159, // Start from top
      3.14159 * 2, // Full circle
    );

    // Bottom point
    path.lineTo(centerX, bottomY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TargetIconFieldPainter extends CustomPainter {
  final Color color;

  TargetIconFieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2 - 2;

    // Draw outer circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Draw inner circle
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.5, paint);

    // Draw center dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
