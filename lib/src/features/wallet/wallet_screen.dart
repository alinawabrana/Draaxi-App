import 'package:draaxi/src/common/widgets/app_drawer.dart';
import 'package:draaxi/src/features/wallet/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletProvider.notifier).ensureInitialized();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopNavigationBar(isDark),
              const SizedBox(height: 30),
              _buildAddMoneyButton(isDark),
              const SizedBox(height: 30),
              _buildBalanceCards(isDark, wallet),
              const SizedBox(height: 30),
              _buildTransactionsSection(isDark, wallet),
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
        _buildIconButton(
          icon: Icons.menu,
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          isDark: isDark,
        ),
        Row(
          children: [
            _buildIconButton(icon: Icons.search, onTap: () {}, isDark: isDark),
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
        child: Icon(icon, size: 16, color: const Color(0xFF414141)),
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
            side: const BorderSide(color: Color(0xFFEDAE10), width: 1),
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

  Widget _buildBalanceCards(bool isDark, WalletState wallet) {
    final balanceText = wallet.isLoaded
        ? '\$${wallet.balance.toStringAsFixed(2)}'
        : '...';
    final spentText = wallet.isLoaded
        ? '\$${wallet.totalSpent.toStringAsFixed(2)}'
        : '...';

    return Row(
      children: [
        Expanded(
          child: _buildBalanceCard(
            amount: balanceText,
            label: 'Available Balance',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          child: _buildBalanceCard(
            amount: spentText,
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
        border: Border.all(color: const Color(0xFFFEC400), width: 1),
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
                color: isDark
                    ? const Color(0xFFD0D0D0)
                    : const Color(0xFF5A5A5A),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(bool isDark, WalletState wallet) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              Text(
                'See All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 18 / 12,
                  color: const Color(0xFFF4BE05),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: wallet.transactions.isEmpty
                ? Center(
                    child: Text(
                      wallet.isLoaded
                          ? 'No wallet transactions yet'
                          : 'Loading wallet...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFD0D0D0)
                            : const Color(0xFF5A5A5A),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: wallet.transactions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(
                        wallet.transactions[index],
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(WalletTransaction transaction, bool isDark) {
    final isMoneyOut = transaction.type == WalletTransactionType.debit;
    final amountText =
        '${isMoneyOut ? '-' : '+'}\$${transaction.amount.abs().toStringAsFixed(2)}';
    final timeOfDay = TimeOfDay.fromDateTime(transaction.timestamp);
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'am' : 'pm';
    final dateText =
        '${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year} at $hour:$minute $period';

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFEC400), width: 1),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF121212),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 12,
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
