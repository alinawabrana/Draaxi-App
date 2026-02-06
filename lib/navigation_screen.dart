import 'dart:math' as math;
import 'package:draaxi/src/router/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationScreen extends StatefulWidget {
  final Widget child;
  const NavigationScreen({super.key, required this.child});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      route: ARouter.home,
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    NavigationItem(
      route: ARouter.favorite,
      label: 'Favorite',
      icon: Icons.favorite_border,
      selectedIcon: Icons.favorite,
    ),
    NavigationItem(
      route: ARouter.wallet,
      label: 'Wallet',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      isWallet: true,
    ),
    NavigationItem(
      route: ARouter.offer,
      label: 'Offer',
      icon: Icons.local_offer_outlined,
      selectedIcon: Icons.local_offer,
    ),
    NavigationItem(
      route: ARouter.profile,
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update current index based on current route
    final location = GoRouterState.of(context).uri.path;
    _currentIndex = _navigationItems.indexWhere(
      (item) => location.contains(item.route),
    );
    if (_currentIndex == -1) {
      _currentIndex = 0;
    }
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      context.go('/${_navigationItems[index].route}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomNavTheme = theme.bottomNavigationBarTheme;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
              Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navigationItems.length,
                (index) => _buildNavItem(
                  context,
                  _navigationItems[index],
                  index,
                  isDark,
                  bottomNavTheme,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavigationItem item,
    int index,
    bool isDark,
    BottomNavigationBarThemeData? bottomNavTheme,
  ) {
    final isSelected = _currentIndex == index;
    final textTheme = Theme.of(context).textTheme;

    // Colors for non-selected items
    final unselectedIconFillColor = isDark
        ? const Color(0xFFD0D0D0)
        : const Color(0xFFC2CCDE).withOpacity(0.25);
    final unselectedIconBorderColor = isDark
        ? const Color(0xFFD0D0D0)
        : const Color(0xFF414141);
    final unselectedLabelColor = isDark
        ? const Color(0xFFD0D0D0)
        : const Color(0xFF414141);

    // Colors for selected items
    const selectedColor = Color(0xFFEDAE10);

    if (item.isWallet) {
      return _buildWalletItem(
        context,
        item,
        index,
        isSelected,
        isDark,
        unselectedLabelColor,
        textTheme,
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 13,
              child: isSelected
                  ? Icon(item.selectedIcon, size: 16, color: selectedColor)
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        // Fill color (filled icon variant)
                        Icon(
                          item.selectedIcon,
                          size: 16,
                          color: unselectedIconFillColor,
                        ),
                        // Border color (outline icon variant)
                        Icon(
                          item.icon,
                          size: 16,
                          color: unselectedIconBorderColor,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? selectedColor : unselectedLabelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletItem(
    BuildContext context,
    NavigationItem item,
    int index,
    bool isSelected,
    bool isDark,
    Color unselectedLabelColor,
    TextTheme textTheme,
  ) {
    const selectedColor = Color(0xFFEDAE10);

    // Wallet icon colors based on mode and selection
    final walletIconColor = isSelected
        ? (isDark ? const Color(0xFF35383F) : Colors.white)
        : (isDark ? const Color(0xFF35383F) : Colors.white);

    // Use outline icon for unselected, filled icon for selected
    final walletIcon = isSelected ? item.selectedIcon : item.icon;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hexagon/Diamond shape container for wallet
            Transform.translate(
              offset: const Offset(0, -15),
              child: CustomPaint(
                size: const Size(50, 50),
                painter: HexagonPainter(color: selectedColor),
                child: Center(
                  child: Icon(walletIcon, size: 24, color: walletIconColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? selectedColor : unselectedLabelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Color color;

  HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // Create a hexagon (6-sided polygon)
    for (int i = 0; i < 6; i++) {
      final angle =
          (i * 60 - 30) *
          math.pi /
          180; // Convert to radians, rotate 30 degrees
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NavigationItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isWallet;

  NavigationItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.isWallet = false,
  });
}
