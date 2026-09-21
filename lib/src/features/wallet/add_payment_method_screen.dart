import 'package:draaxi/utils/constant/texts.dart';
import 'package:flutter/material.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final TextEditingController _accountNumberController = TextEditingController();
  String? _selectedPaymentMethod;

  final List<String> _paymentMethodOptions = [
    'VISA',
    'Mastercard',
    'PayPal',
    'Cash',
  ];

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top navigation bar
              _buildTopBar(isDark, textTheme),
              
              const SizedBox(height: 39),
              
              // Select Payment Method dropdown
              _buildPaymentMethodDropdown(isDark),
              
              const SizedBox(height: 20),
              
              // Account Number input field
              TextField(
                controller: _accountNumberController,
                keyboardType: TextInputType.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF121212),
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  hintText: 'Account Number',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFD0D0D0),
                    fontFamily: 'Poppins',
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF35383F) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFB8B8B8),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFB8B8B8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFB8B8B8),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Save Payment Method button
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF35383F) : const Color(0xFFFFFBE7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFEC400),
                    width: 1,
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement save payment method functionality
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Payment methods list
              Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF414141),
                  fontFamily: 'Poppins',
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Payment method cards list
              Expanded(
                child: ListView.separated(
                  itemCount: _paymentMethodOptions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildPaymentMethodCard(
                      _paymentMethodOptions[index],
                      index,
                      isDark,
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

  Widget _buildTopBar(bool isDark, TextTheme textTheme) {
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
          'Amount',
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

  Widget _buildPaymentMethodDropdown(bool isDark) {
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPaymentMethod,
          isExpanded: true,
          hint: Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD0D0D0),
              fontFamily: 'Poppins',
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF414141),
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF121212),
            fontFamily: 'Poppins',
          ),
          dropdownColor: isDark ? const Color(0xFF35383F) : Colors.white,
          items: _paymentMethodOptions.map((String method) {
            return DropdownMenuItem<String>(
              value: method,
              child: Text(method),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedPaymentMethod = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    String paymentMethod,
    int index,
    bool isDark,
  ) {
    // Determine icon and details based on payment method
    IconData icon;
    String number;
    
    switch (paymentMethod) {
      case 'VISA':
        icon = Icons.credit_card;
        number = '**** **** **** 8970';
        break;
      case 'Mastercard':
        icon = Icons.credit_card;
        number = '**** **** **** 8970';
        break;
      case 'PayPal':
        icon = Icons.payment;
        number = 'mailaddress@mail.com';
        break;
      case 'Cash':
        icon = Icons.money;
        number = 'Cash';
        break;
      default:
        icon = Icons.credit_card;
        number = '**** **** **** 8970';
    }

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : const Color(0xFFFFFBE7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFFEC400),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Payment method icon
          Container(
            width: 45,
            height: 35,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF414141),
            ),
          ),
          
          const SizedBox(width: 13),
          
          // Payment method details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  number,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF121212),
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Expires: 12/26',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.15,
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
        ],
      ),
    );
  }
}

