import 'package:draaxi/src/common/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Static transaction data for now
  final List<Map<String, dynamic>> _transactions = [
    {
      'name': 'Welton',
      'date': 'Today at 09:20 am',
      'amount': -570.00,
      'type': 'out', // money out
    },
    {
      'name': 'Nathsam',
      'date': 'Today at 09:20 am',
      'amount': 570.00,
      'type': 'in', // money in
    },
    {
      'name': 'Welton',
      'date': 'Today at 09:20 am',
      'amount': -570.00,
      'type': 'out',
    },
    {
      'name': 'Nathsam',
      'date': 'Today at 09:20 am',
      'amount': 570.00,
      'type': 'in',
    },
    {
      'name': 'Nathsam',
      'date': 'Today at 09:20 am',
      'amount': 570.00,
      'type': 'in',
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
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top navigation bar
              _buildTopNavigationBar(isDark),
              
              const SizedBox(height: 30),
              
              // Add Money button row
              _buildAddMoneyButton(isDark),
              
              const SizedBox(height: 30),
              
              // Balance cards
              _buildBalanceCards(isDark),
              
              const SizedBox(height: 30),
              
              // Transactions section
              _buildTransactionsSection(isDark),
            ],
          ),
        ),
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

  Widget _buildAddMoneyButton(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
            context.push('/wallet/addMoney');
          },
          style: OutlinedButton.styleFrom(
            fixedSize: const Size(171, 54),
            side: const BorderSide(
              color: Color(0xFFEDAE10),
              width: 1,
            ),
            backgroundColor: isDark ? const Color(0xFF35383F) : Colors.white,
            foregroundColor: const Color(0xFFEDAE10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Add Money',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCards(bool isDark) {
    return Row(
      children: [
        // Available Balance card
        Expanded(
          child: _buildBalanceCard(
            amount: '\$500',
            label: 'Available Balance',
            isDark: isDark,
          ),
        ),
        
        const SizedBox(width: 30),
        
        // Total Expend card
        Expanded(
          child: _buildBalanceCard(
            amount: '\$200',
            label: 'Total Expend',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard({
    required String amount,
    required String label,
    required bool isDark,
  }) {
    return Container(
      width: 165,
      height: 145,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : const Color(0xFFFFFBE7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFEC400),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              amount,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF5A5A5A),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 21),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transactions header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF414141),
                  fontFamily: 'Poppins',
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to all transactions
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 18 / 12,
                    color: const Color(0xFFF4BE05),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Transactions list
          Expanded(
            child: ListView.separated(
              itemCount: _transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildTransactionCard(
                  _transactions[index],
                  isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    Map<String, dynamic> transaction,
    bool isDark,
  ) {
    final isMoneyOut = transaction['type'] == 'out';
    final amount = transaction['amount'] as double;
    final amountText = amount >= 0
        ? '\$${amount.toStringAsFixed(2)}'
        : '-\$${amount.abs().toStringAsFixed(2)}';

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFEC400),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMoneyOut
                  ? const Color(0xFFFFCDD2)
                  : const Color(0xFFC8E6C9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMoneyOut ? Icons.trending_up : Icons.trending_down,
              size: 20,
              color: isMoneyOut
                  ? const Color(0xFFD32F2F)
                  : const Color(0xFF388E3C),
            ),
          ),
          
          const SizedBox(width: 13),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name
                Text(
                  transaction['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF121212),
                    fontFamily: 'Poppins',
                  ),
                ),
                
                const SizedBox(height: 2),
                
                // Date and time
                Text(
                  transaction['date'] as String,
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
          
          // Amount
          Text(
            amountText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF121212),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
