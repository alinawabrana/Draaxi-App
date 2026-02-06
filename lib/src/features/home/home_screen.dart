import 'dart:ui' as ui;
import 'package:draaxi/src/common/widgets/app_drawer.dart';
import 'package:draaxi/src/features/home/address_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();
  int _selectedService = 0; // 0 for Transport, 1 for Delivery
  final LatLng _currentLocation = const LatLng(37.7749, -122.4194); // Default location

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = 70.0; // Height of bottom navigation bar
    final walletIconOffset = 15.0; // 15px above Wallet icon
    final containerHeight = 141.0;
    
    // Calculate the position of the search container
    // It should be 15px above the Wallet icon in the bottom nav
    final searchContainerBottom = safeAreaBottom + bottomNavHeight + walletIconOffset;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Map covering the whole screen
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.draaxi',
                maxZoom: 19,
              ),
            ],
          ),
          
          // Top navigation bar with 15px padding
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: _buildTopNavigationBar(isDark),
            ),
          ),
          
          // Rental button and location target icon row - positioned 15px above search container
          Positioned(
            bottom: searchContainerBottom + containerHeight + 15,
            left: 15,
            right: 15,
            child: _buildRentalAndLocationRow(isDark),
          ),
          
          // Search container - positioned 15px above Wallet icon
          Positioned(
            bottom: searchContainerBottom,
            left: 15,
            right: 15,
            child: _buildSearchContainer(isDark),
          ),
          
          // Marker with concentric circles
          Center(
            child: _buildMarkerWithCircles(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigationBar(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menu icon
        _buildIconButton(
          icon: Icons.menu,
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          isDark: isDark,
        ),
        
        // Search and bell icons
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
        ),
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
        child: Icon(
          icon,
          size: 16,
          color: const Color(0xFF414141),
        ),
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
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF35383F) : Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: CustomPaint(
            size: const Size(34, 34),
            painter: TargetIconPainter(
              color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchContainer(bool isDark) {
    return Container(
      constraints: const BoxConstraints(minHeight: 141),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F212A) : const Color(0xFFFFFBE7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF3BD06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.only(
        top: 13,
        bottom: 11,
        left: 14,
        right: 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search bar
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF35383F) : const Color(0xFFFFFBE7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFF3BD06),
                width: 1,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddressSelectionSheet(),
                );
              },
              child: AbsorbPointer(
                child: TextField(
                  style: TextStyle(
                    color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFFA0A0A0),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 23 / 16,
                    fontFamily: 'Poppins',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Where would you go?',
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFFA0A0A0),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 23 / 16,
                      fontFamily: 'Poppins',
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 24,
                      color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFFA0A0A0),
                    ),
                    suffixIcon: Icon(
                      Icons.favorite,
                      size: 24,
                      color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFFA0A0A0),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 13),
          
          // Transport/Delivery switch
          _buildServiceSwitch(isDark),
        ],
      ),
    );
  }

  Widget _buildServiceSwitch(bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : const Color(0xFFFFFBE7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF3BD06),
          width: 1,
        ),
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

  Widget _buildMarkerWithCircles(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outermost circle - 224x224, 10% opacity
        Container(
          width: 224,
          height: 224,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFEC400).withOpacity(0.10),
          ),
        ),
        
        // Second circle - 154.28x154.28, 15% opacity
        Container(
          width: 154.28,
          height: 154.28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFEC400).withOpacity(0.15),
          ),
        ),
        
        // Third circle - 72.69x72.69, 25% opacity
        Container(
          width: 72.69,
          height: 72.69,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFEC400).withOpacity(0.25),
          ),
        ),
        
        // Fourth circle - 28.19x28.19, 50% opacity
        Container(
          width: 28.19,
          height: 28.19,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFEC400).withOpacity(0.50),
          ),
        ),
        
        // Marker icon - 9x12.4
        CustomPaint(
          size: const Size(9, 12.4),
          painter: MarkerPainter(),
        ),
      ],
    );
  }
}

class MarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF414141)
      ..style = PaintingStyle.fill;

    final path = ui.Path();
    
    // Draw a location pin shape
    // Starting from the bottom point
    final bottomX = size.width / 2;
    final bottomY = size.height;
    
    // Top point
    final topX = size.width / 2;
    final topY = 0.0;
    
    // Left and right points for the triangle base
    final leftX = 0.0;
    final rightX = size.width;
    final baseY = size.height * 0.7;
    
    path.moveTo(bottomX, bottomY);
    path.lineTo(leftX, baseY);
    path.lineTo(topX, topY);
    path.lineTo(rightX, baseY);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
