import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:draaxi/utils/constant/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  // Static referral code - in real app, this would come from API
  final String _referralCode = 'RkMFucd';

  void _copyReferralCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

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
              
              // Refer a friend text
              Text(
                'Refer a friend and Earn \$20',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 23 / 16,
                  color: isDark ? Colors.white : const Color(0xFF5A5A5A),
                  fontFamily: 'Poppins',
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Referral code field
              _buildReferralCodeField(context, isDark),
              
              const SizedBox(height: 32),
              
              // Invite button
              PrimaryButton(
                text: 'Invite',
                onPressed: () {
                  // TODO: Implement invite functionality
                  // Could open share dialog or send invitation
                },
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
          'Referral',
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

  Widget _buildReferralCodeField(BuildContext context, bool isDark) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFB8B8B8),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Referral code text
          Expanded(
            child: Text(
              _referralCode,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF414141),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          
          // Copy icon
          GestureDetector(
            onTap: () => _copyReferralCode(context),
            child: Icon(
              Icons.copy,
              size: 24,
              color: isDark
                  ? const Color(0xFFD0D0D0)
                  : const Color(0xFFC2CCDE).withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }
}

