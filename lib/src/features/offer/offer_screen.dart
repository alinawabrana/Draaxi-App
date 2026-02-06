import 'package:draaxi/src/common/widgets/app_drawer.dart';
import 'package:draaxi/src/features/offer/offer_detail_sheet.dart';
import 'package:flutter/material.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Static offer data
  final List<Map<String, dynamic>> _offers = [
    {
      'title': 'Discount 15% off',
      'description': 'Special Promo valid for Black Friday',
      'icon': 'shopping bag red.png',
      'code': 'DISC35',
    },
    {
      'title': 'Special 5% off',
      'description': 'Special Weekend deal promo',
      'icon': 'shopping bag green.png',
      'code': 'SPEC5',
    },
    {
      'title': 'Cashback 15%',
      'description': 'Special Promo valid for today',
      'icon': 'shopping bag red.png',
      'code': 'CASH15',
    },
    {
      'title': 'Special 15% off',
      'description': 'Special Promo valid for Black Friday',
      'icon': 'shopping bag red.png',
      'code': 'SPEC15',
    },
    {
      'title': 'Discount 15% off',
      'description': 'Special Promo valid for Black Friday',
      'icon': 'shopping bag red.png',
      'code': 'DISC35',
    },
    {
      'title': 'Discount 15% off',
      'description': 'Special Promo valid for Black Friday',
      'icon': 'shopping bag green.png',
      'code': 'DISC35',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top navigation bar
              _buildTopBar(isDark),
              
              const SizedBox(height: 30),
              
              // Offer cards list
              Expanded(
                child: ListView.separated(
                  itemCount: _offers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    return _buildOfferCard(_offers[index], isDark, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
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
        
        // Title
        Text(
          'Special Offer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 25 / 18,
            color: isDark ? Colors.white : const Color(0xFF2A2A2A),
            fontFamily: 'Poppins',
          ),
        ),
        
        // Spacer to balance
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
        child: Icon(
          icon,
          size: 16,
          color: const Color(0xFF414141),
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    Map<String, dynamic> offer,
    bool isDark,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => OfferDetailSheet(offer: offer),
        );
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF35383F) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFFEC400),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1B1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFE773),
                  width: 1,
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/${offer['icon']}',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Offer details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Offer title
                  Text(
                    offer['title'] as String,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 25 / 18,
                      color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  // Offer description
                  Text(
                    offer['description'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFB8B8B8),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
