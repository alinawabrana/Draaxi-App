import 'package:flutter/material.dart';

class ARouter {
  // Keys
  static final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellKey = GlobalKey<NavigatorState>();

  static const String onboarding = 'onBoarding';

  //Authentication
  static const String welcome = 'welcome';
  static const String signUp = 'signUp';
  static const String signIn = 'signIn';
  static const String otpVerification = 'otpVerification';
  static const String forgotPasswordOtpVerification =
      'forgotPasswordOtpVerification';
  static const String setPassword = 'setPassword';
  static const String setNewPassword = 'setNewPassword';
  static const String sendVerification = 'sendVerification';
  static const String forgotPassword = 'forgotPassword';

  // Bottom Navigation
  static const String home = 'home';
  static const String favorite = 'favorite';
  static const String wallet = 'wallet';
  static const String offer = 'offer';
  static const String profile = 'profile';

  // Wallet
  static const String addMoney = 'addMoney';
  static const String addPaymentMethod = 'addPaymentMethod';

  // History
  static const String history = 'history';
  
  // Complaints
  static const String complaints = 'complaints';
  
  // About Us
  static const String aboutUs = 'aboutUs';
  
  // Referral
  static const String referral = 'referral';
  
  // Address
  static const String address = 'address';
}
