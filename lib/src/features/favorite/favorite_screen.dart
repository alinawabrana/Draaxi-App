import 'package:draaxi/src/common/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Static favorite locations for now
  final List<Map<String, String>> _favoriteLocations = [
    {'name': 'Office', 'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486'},
    {'name': 'Home', 'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486'},
    {'name': 'Office', 'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486'},
    {'name': 'House', 'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486'},
    {'name': 'Home', 'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486'},
    {'name': 'Office', 'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486'},
    {'name': 'House', 'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486'},
    {'name': 'House', 'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with menu icon and Favorite title
              _buildTopRow(isDark, textTheme),
              
              const SizedBox(height: 30),
              
              // Favorite locations list
              Expanded(
                child: ListView.separated(
                  itemCount: _favoriteLocations.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildFavoriteCard(
                      _favoriteLocations[index],
                      isDark,
                      textTheme,
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(bool isDark, TextTheme textTheme) {
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
        
        // Favorite title (centered)
        Expanded(
          child: Center(
            child: Text(
              'Favourite',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 25 / 18,
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        
        // Spacer to balance the menu icon
        SizedBox(
          width: 34,
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

  Widget _buildFavoriteCard(
    Map<String, String> location,
    bool isDark,
    TextTheme textTheme,
    int index,
  ) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFF1B1),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(11),
      child: Row(
        children: [
          // Location icon
          Icon(
            Icons.location_on,
            size: 24,
            color: isDark ? Colors.white : const Color(0xFF414141),
          ),
          
          const SizedBox(width: 6),
          
          // Location details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Location name
                Text(
                  location['name'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 23 / 16,
                    color: isDark ? Colors.white : const Color(0xFF414141),
                    fontFamily: 'Poppins',
                  ),
                ),
                
                const SizedBox(height: 2),
                
                // Address
                Text(
                  location['address'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 18 / 12,
                    color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFFB8B8B8),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          
          // Remove icon
          GestureDetector(
            onTap: () {
              _removeFavorite(index);
            },
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFFE57373) : const Color(0xFFB7083C),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.remove,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeFavorite(int index) {
    setState(() {
      _favoriteLocations.removeAt(index);
    });
  }
}
