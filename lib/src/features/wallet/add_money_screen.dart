import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:draaxi/src/router/router.dart';
import 'package:draaxi/src/features/wallet/wallet_provider.dart';
import 'package:draaxi/utils/constant/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddMoneyScreen extends ConsumerStatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  ConsumerState<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends ConsumerState<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  int? _selectedPaymentMethodIndex;

  // Static payment methods for now
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'visa',
      'name': 'VISA',
      'number': '**** **** **** 8970',
      'expiry': '12/26',
      'icon': Icons.credit_card,
    },
    {
      'type': 'mastercard',
      'name': 'Mastercard',
      'number': '**** **** **** 8970',
      'expiry': '12/26',
      'icon': Icons.credit_card,
    },
    {
      'type': 'paypal',
      'name': 'PayPal',
      'number': 'mailaddress@mail.com',
      'expiry': '12/26',
      'icon': Icons.payment,
    },
    {
      'type': 'cash',
      'name': 'Cash',
      'number': 'Cash',
      'expiry': '12/26',
      'icon': Icons.money,
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletProvider.notifier).ensureInitialized();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
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

              // Amount input field
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF121212),
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Amount',
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

              const SizedBox(height: 8),

              // Add Payment Method button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      context.pushNamed(ARouter.addPaymentMethod);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Add Payment Method',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF304FFE)
                            : const Color(0xFF304FFE),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Select Payment Method title
              Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF414141),
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 30),

              // Payment method cards
              Expanded(
                child: ListView.separated(
                  itemCount: _paymentMethods.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildPaymentMethodCard(
                      _paymentMethods[index],
                      index,
                      isDark,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Confirm button
              PrimaryButton(
                text: 'Confirm',
                onPressed: () async {
                  final amount =
                      double.tryParse(_amountController.text.trim()) ?? 0;
                  if (_selectedPaymentMethodIndex != null && amount > 0) {
                    final selectedMethod =
                        _paymentMethods[_selectedPaymentMethodIndex!]['name']
                            .toString();
                    await ref
                        .read(walletProvider.notifier)
                        .addMoney(amount, source: '$selectedMethod top-up');
                    if (!context.mounted) return;
                    context.pop();
                  }
                },
                enabled:
                    _selectedPaymentMethodIndex != null &&
                    (double.tryParse(_amountController.text.trim()) ?? 0) > 0,
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
          onTap: () => context.pop(),
          child: Row(
            children: [
              SizedBox(
                width: 8.5,
                height: 15.5,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 8.5,
                  color: isDark
                      ? const Color(0xFFD0D0D0)
                      : const Color(0xFF2A2A2A),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ATexts.back,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? const Color(0xFFD0D0D0)
                      : const Color(0xFF414141),
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

  Widget _buildPaymentMethodCard(
    Map<String, dynamic> paymentMethod,
    int index,
    bool isDark,
  ) {
    final isSelected = _selectedPaymentMethodIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethodIndex = index;
        });
      },
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.5,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF35383F) : const Color(0xFFFFFBE7),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFEC400)
                  : const Color(0x4DFEC400),
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
                  paymentMethod['icon'] as IconData,
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
                      paymentMethod['number'] as String,
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
                      'Expires: ${paymentMethod['expiry']}',
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
        ),
      ),
    );
  }
}
