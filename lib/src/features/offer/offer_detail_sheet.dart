import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OfferDetailSheet extends StatelessWidget {
  final Map<String, dynamic> offer;

  const OfferDetailSheet({
    super.key,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 134,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : const Color(0xFF141414),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'Special Offer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: const Color(0xFFDDDDDD),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Discount tag image
                  Center(
                    child: Image.asset(
                      'assets/icons/discount tag.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  const SizedBox(height: 22),
                  
                  // Offer title
                  Center(
                    child: Text(
                      offer['title'] as String,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  // Offer description
                  Center(
                    child: Text(
                      offer['description'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFB8B8B8),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Promo code container
                  Center(
                    child: Container(
                      width: 130,
                      height: 39,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFFF0BF).withOpacity(0.64),
                            const Color(0xFFF1BD0E).withOpacity(0.64),
                          ],
                          stops: const [0.3375, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            offer['code'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2A2A2A),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: offer['code'] as String),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Promo code copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.copy,
                              size: 18,
                              color: const Color(0xFF2A2A2A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Dashed divider
                  CustomPaint(
                    painter: DashedLinePainter(
                      color: const Color(0xFFB8B8B8),
                    ),
                    size: Size(MediaQuery.of(context).size.width - 40, 1),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Terms and Conditions
                  Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Terms text
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris. '
                    'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
                      fontFamily: 'Poppins',
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Use Promo button
                  PrimaryButton(
                    text: 'Use Promo',
                    onPressed: () {
                      // TODO: Implement use promo functionality
                      Navigator.pop(context);
                    },
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

