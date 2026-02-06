import 'package:draaxi/utils/constant/texts.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top navigation bar
              _buildTopBar(context, isDark),
              
              const SizedBox(height: 30),
              
              // About Us content
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'Professional Rideshare Platform. Here we will provide you only interesting content, which you will like very much. We\'re dedicated to providing you the best of Rideshare, with a focus on dependability and Earning. We\'re working to turn our passion for Rideshare into a booming online website. We hope you enjoy our Rideshare as much as we enjoy offering them to you. I will keep posting more important posts on my Website for all of you. Please give your support and love.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 22 / 14,
                      color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              SizedBox(
                width: 8.5,
                height: 15.5,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 8.5,
                  color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF2A2A2A),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ATexts.back,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF414141),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        
        // Title
        Text(
          'About Us',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF2A2A2A),
            fontFamily: 'Poppins',
          ),
        ),
        
        // Spacer to balance
        const SizedBox(width: 80),
      ],
    );
  }
}

