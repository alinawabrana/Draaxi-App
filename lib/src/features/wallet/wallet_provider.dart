import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);

class WalletNotifier extends Notifier<WalletState> {
  static const String _balanceKey = 'wallet_balance';
  static const String _totalSpentKey = 'wallet_total_spent';
  static const String _transactionsKey = 'wallet_transactions';
  static const double _defaultBalance = 500;

  bool _initialized = false;

  @override
  WalletState build() => const WalletState();

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    final balance = prefs.getDouble(_balanceKey) ?? _defaultBalance;
    final totalSpent = prefs.getDouble(_totalSpentKey) ?? 0;
    final rawTransactions = prefs.getStringList(_transactionsKey) ?? const [];
    final transactions = rawTransactions
        .map((item) => WalletTransaction.fromJson(jsonDecode(item)))
        .toList(growable: false);

    state = WalletState(
      isLoaded: true,
      balance: balance,
      totalSpent: totalSpent,
      transactions: transactions,
    );
  }

  bool canAfford(double amount) => state.isLoaded && state.balance >= amount;

  Future<void> addMoney(
    double amount, {
    String source = 'Wallet top-up',
  }) async {
    await ensureInitialized();
    if (amount <= 0) return;

    final transaction = WalletTransaction(
      title: source,
      timestamp: DateTime.now(),
      amount: amount,
      type: WalletTransactionType.credit,
    );
    state = state.copyWith(
      balance: state.balance + amount,
      transactions: <WalletTransaction>[transaction, ...state.transactions],
    );
    await _persist();
  }

  Future<bool> chargeRide({
    required double amount,
    required String driverName,
  }) async {
    await ensureInitialized();
    if (amount <= 0 || state.balance < amount) {
      return false;
    }

    final transaction = WalletTransaction(
      title: 'Ride with $driverName',
      timestamp: DateTime.now(),
      amount: amount,
      type: WalletTransactionType.debit,
    );
    state = state.copyWith(
      balance: state.balance - amount,
      totalSpent: state.totalSpent + amount,
      transactions: <WalletTransaction>[transaction, ...state.transactions],
    );
    await _persist();
    return true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, state.balance);
    await prefs.setDouble(_totalSpentKey, state.totalSpent);
    await prefs.setStringList(
      _transactionsKey,
      state.transactions
          .take(30)
          .map((item) => jsonEncode(item.toJson()))
          .toList(growable: false),
    );
  }
}

class WalletState {
  const WalletState({
    this.isLoaded = false,
    this.balance = 0,
    this.totalSpent = 0,
    this.transactions = const <WalletTransaction>[],
  });

  final bool isLoaded;
  final double balance;
  final double totalSpent;
  final List<WalletTransaction> transactions;

  WalletState copyWith({
    bool? isLoaded,
    double? balance,
    double? totalSpent,
    List<WalletTransaction>? transactions,
  }) {
    return WalletState(
      isLoaded: isLoaded ?? this.isLoaded,
      balance: balance ?? this.balance,
      totalSpent: totalSpent ?? this.totalSpent,
      transactions: transactions ?? this.transactions,
    );
  }
}

enum WalletTransactionType { credit, debit }

class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.timestamp,
    required this.amount,
    required this.type,
  });

  final String title;
  final DateTime timestamp;
  final double amount;
  final WalletTransactionType type;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'type': type.name,
    };
  }

  factory WalletTransaction.fromJson(dynamic json) {
    final map = Map<String, dynamic>.from(json as Map);
    return WalletTransaction(
      title: (map['title'] ?? '').toString(),
      timestamp:
          DateTime.tryParse((map['timestamp'] ?? '').toString()) ??
          DateTime.now(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      type: (map['type'] ?? '') == WalletTransactionType.debit.name
          ? WalletTransactionType.debit
          : WalletTransactionType.credit,
    );
  }
}
