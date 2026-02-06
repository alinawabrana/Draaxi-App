import 'package:draaxi/navigation_screen.dart';
import 'package:draaxi/onboarding_screen.dart';
import 'package:draaxi/src/features/authentication/providers/auth_providers.dart';
import 'package:draaxi/src/features/authentication/screens/forgot_password_screen.dart';
import 'package:draaxi/src/features/authentication/screens/otp_verification_screen.dart';
import 'package:draaxi/src/features/authentication/screens/set_password_screen.dart';
import 'package:draaxi/src/features/authentication/screens/signin_screen.dart';
import 'package:draaxi/src/features/authentication/screens/signup_screen.dart';
import 'package:draaxi/src/features/authentication/screens/welcome_screen.dart';
import 'package:draaxi/src/features/about_us/about_us_screen.dart';
import 'package:draaxi/src/features/address/address_screen.dart';
import 'package:draaxi/src/features/complaints/complaints_screen.dart';
import 'package:draaxi/src/features/favorite/favorite_screen.dart';
import 'package:draaxi/src/features/referral/referral_screen.dart';
import 'package:draaxi/src/features/history/history_screen.dart';
import 'package:draaxi/src/features/home/home_screen.dart';
import 'package:draaxi/src/features/offer/offer_screen.dart';
import 'package:draaxi/src/features/profile/profile_screen.dart';
import 'package:draaxi/src/features/wallet/add_money_screen.dart';
import 'package:draaxi/src/features/wallet/add_payment_method_screen.dart';
import 'package:draaxi/src/features/wallet/wallet_screen.dart';
import 'package:draaxi/src/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static GoRouter routes(WidgetRef ref) => GoRouter(
    initialLocation: '/onBoarding',
    redirect: (context, state) {
      final authRepository = ref.read(authRepositoryProvider);
      final isAuthenticated = authRepository.isAuthenticated;
      final isOnBoarding = state.uri.path == '/onBoarding';
      final isAuthRoute = state.uri.path.startsWith('/welcome');
      final isHomeRoute =
          state.uri.path.startsWith('/home') ||
          state.uri.path.startsWith('/favorite') ||
          state.uri.path.startsWith('/wallet') ||
          state.uri.path.startsWith('/offer') ||
          state.uri.path.startsWith('/profile');

      // If authenticated and trying to access auth routes, redirect to home
      if (isAuthenticated && (isAuthRoute || isOnBoarding)) {
        return '/home';
      }

      // If not authenticated and trying to access protected routes, redirect to welcome
      if (!isAuthenticated && isHomeRoute) {
        return '/welcome';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/onBoarding',
        name: ARouter.onboarding,
        builder: (context, state) => const OnBoardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: ARouter.welcome,
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: '/signUp',
            name: ARouter.signUp,
            builder: (context, state) => const SignUpScreen(),
            routes: [
              GoRoute(
                path: '/otpVerification',
                name: ARouter.otpVerification,
                builder: (context, state) => const OtpVerificationScreen(),
                routes: [
                  GoRoute(
                    path: '/setPassword',
                    name: ARouter.setPassword,
                    builder: (context, state) => const SetPasswordScreen(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/signIn',
            name: ARouter.signIn,
            builder: (context, state) => const SignInScreen(),
            routes: [
              GoRoute(
                path: '/forgotPassword',
                name: ARouter.forgotPassword,
                builder: (context, state) => const ForgotPasswordScreen(),
                routes: [
                  GoRoute(
                    path: '/otpVerification',
                    name: ARouter.forgotPasswordOtpVerification,
                    builder: (context, state) => const OtpVerificationScreen(),
                    routes: [
                      GoRoute(
                        path: '/setNewPassword',
                        name: ARouter.setNewPassword,
                        builder: (context, state) => const SetPasswordScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ShellRoute(
        navigatorKey: ARouter.shellKey,
        pageBuilder: (context, state, child) =>
            MaterialPage(child: NavigationScreen(child: child)),
        routes: [
          GoRoute(
            parentNavigatorKey: ARouter.shellKey,
            path: '/home',
            name: ARouter.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            parentNavigatorKey: ARouter.shellKey,
            path: '/favorite',
            name: ARouter.favorite,
            builder: (context, state) => const FavoriteScreen(),
          ),
          GoRoute(
            parentNavigatorKey: ARouter.shellKey,
            path: '/wallet',
            name: ARouter.wallet,
            builder: (context, state) => const WalletScreen(),
            routes: [
              GoRoute(
                path: '/addMoney',
                name: ARouter.addMoney,
                builder: (context, state) => const AddMoneyScreen(),
                routes: [
                  GoRoute(
                    path: '/addPaymentMethod',
                    name: ARouter.addPaymentMethod,
                    builder: (context, state) => const AddPaymentMethodScreen(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            parentNavigatorKey: ARouter.shellKey,
            path: '/offer',
            name: ARouter.offer,
            builder: (context, state) => const OfferScreen(),
          ),
          GoRoute(
            parentNavigatorKey: ARouter.shellKey,
            path: '/profile',
            name: ARouter.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/history',
        name: ARouter.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/complaints',
        name: ARouter.complaints,
        builder: (context, state) => const ComplaintsScreen(),
      ),
      GoRoute(
        path: '/aboutUs',
        name: ARouter.aboutUs,
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: '/referral',
        name: ARouter.referral,
        builder: (context, state) => const ReferralScreen(),
      ),
      GoRoute(
        path: '/address',
        name: ARouter.address,
        builder: (context, state) => const AddressScreen(),
      ),
    ],
  );
}
