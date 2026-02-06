import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class AddressSelectionSheet extends StatefulWidget {
  const AddressSelectionSheet({super.key});

  @override
  State<AddressSelectionSheet> createState() => _AddressSelectionSheetState();
}

class _AddressSelectionSheetState extends State<AddressSelectionSheet> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  
  Map<String, dynamic>? _selectedFromPlace;
  Map<String, dynamic>? _selectedToPlace;

  // Static recent places data
  final List<Map<String, dynamic>> _recentPlaces = [
    {
      'name': 'Office',
      'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486',
      'distance': '2.7km',
      'lat': 37.7749,
      'lng': -122.4194,
    },
    {
      'name': 'Coffee shop',
      'address': '1901 Thornridge Cir. Shiloh, Hawaii 81063',
      'distance': '1.1km',
      'lat': 37.7849,
      'lng': -122.4094,
    },
    {
      'name': 'Shopping center',
      'address': '4140 Parker Rd. Allentown, New Mexico 31134',
      'distance': '4.9km',
      'lat': 37.7649,
      'lng': -122.4294,
    },
    {
      'name': 'Shopping mall',
      'address': '4140 Parker Rd. Allentown, New Mexico 31134',
      'distance': '4.0km',
      'lat': 37.7549,
      'lng': -122.4394,
    },
  ];

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
  }

  void _selectCurrentLocation({required bool isFrom}) {
    setState(() {
      if (isFrom) {
        _selectedFromPlace = {
          'name': 'Current location',
          'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486',
          'distance': '0km',
          'lat': 37.7749,
          'lng': -122.4194,
          'isCurrent': true,
        };
        _fromController.text = 'Current location';
      } else {
        _selectedToPlace = {
          'name': 'Current location',
          'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486',
          'distance': '0km',
          'lat': 37.7749,
          'lng': -122.4194,
          'isCurrent': true,
        };
        _toController.text = 'Current location';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final hasSelections = _selectedFromPlace != null && _selectedToPlace != null;

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
            color: isDark ? const Color(0xFFDDDDDD).withOpacity(0.3) : const Color(0xFFDDDDDD),
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
            hint: 'Form',
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
            color: isDark ? const Color(0xFFDDDDDD).withOpacity(0.3) : const Color(0xFFDDDDDD),
          ),

          const SizedBox(height: 20),

          // Recent Places section
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

          // Recent places list
          ..._recentPlaces.map((place) => _buildRecentPlaceCard(place, isDark)),
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
          border: Border.all(
            color: const Color(0xFFB8B8B8),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Custom target icon for "From" field
            if (isFrom)
              CustomPaint(
                size: const Size(24, 24),
                painter: TargetIconFieldPainter(
                  color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
                ),
              )
            else
              Icon(
                icon,
                size: 24,
                color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
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
                    color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
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
      builder: (context) => Container(
        height: 300,
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Current location option
                  ListTile(
                    leading: Icon(
                      Icons.my_location,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Current location',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: Text(
                      '2972 Westheimer Rd. Santa Ana, Illinois 85486',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _selectCurrentLocation(isFrom: isFrom);
                    },
                  ),
                  ..._recentPlaces.map((place) => ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: Colors.amber,
                        ),
                        title: Text(
                          place['name'] as String,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        subtitle: Text(
                          place['address'] as String,
                          style: TextStyle(
                            color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        trailing: Text(
                          place['distance'] as String,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _selectPlace(place, isFrom: isFrom);
                        },
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPlaceCard(Map<String, dynamic> place, bool isDark) {
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
                      color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
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
          _buildLocationRow(
            place: _selectedFromPlace!,
            isDark: isDark,
            isCurrent: fromIsCurrent,
            isRed: fromIsCurrent,
          ),

          const SizedBox(height: 20),

          // Dotted line connecting the two locations
          CustomPaint(
            size: const Size(double.infinity, 40),
            painter: DottedLinePainter(
              color: const Color(0xFFFEC400),
            ),
          ),

          const SizedBox(height: 20),

          // To location
          _buildLocationRow(
            place: _selectedToPlace!,
            isDark: isDark,
            isCurrent: toIsCurrent,
            isRed: toIsCurrent,
          ),

          const SizedBox(height: 40),

          // Confirm Location button
          PrimaryButton(
            text: 'Confirm Location',
            onPressed: () {
              Navigator.pop(context);
              // TODO: Handle location confirmation
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
        Container(
          width: 30,
          height: 40,
          child: CustomPaint(
            size: const Size(20, 30),
            painter: PinPainter(
              color: isRed ? Colors.red : Colors.amber,
            ),
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
                  color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
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

