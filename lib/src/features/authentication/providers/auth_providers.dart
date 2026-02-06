import 'package:draaxi/src/features/authentication/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ResetMethod { sms, email }

enum OtpVerificationType { phoneVerification, forgotPassword }

class ForgotPasswordState {
  const ForgotPasswordState({
    this.resetMethod = ResetMethod.sms,
    this.contactDetail = '***** ***70',
  });

  final ResetMethod resetMethod;
  final String contactDetail;

  ForgotPasswordState copyWith({
    ResetMethod? resetMethod,
    String? contactDetail,
  }) {
    return ForgotPasswordState(
      resetMethod: resetMethod ?? this.resetMethod,
      contactDetail: contactDetail ?? this.contactDetail,
    );
  }
}

class OtpVerificationState {
  const OtpVerificationState({
    this.type = OtpVerificationType.phoneVerification,
    this.contactDetail,
    this.token,
  });

  final OtpVerificationType type;
  final String? contactDetail;
  final String? token;

  OtpVerificationState copyWith({
    OtpVerificationType? type,
    String? contactDetail,
    String? token,
  }) {
    return OtpVerificationState(
      type: type ?? this.type,
      contactDetail: contactDetail ?? this.contactDetail,
      token: token ?? this.token,
    );
  }
}

// Provider for forgot password state
class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  void setResetMethod(ResetMethod method, String contactDetail) {
    state = state.copyWith(resetMethod: method, contactDetail: contactDetail);
  }

  void reset() {
    state = const ForgotPasswordState();
  }
}

final forgotPasswordProvider =
    NotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
      ForgotPasswordNotifier.new,
    );

// Provider for OTP verification state
class OtpVerificationNotifier extends Notifier<OtpVerificationState> {
  @override
  OtpVerificationState build() => const OtpVerificationState();

  void setType(OtpVerificationType type, {String? contactDetail, String? token}) {
    state = state.copyWith(type: type, contactDetail: contactDetail, token: token);
  }

  void reset() {
    state = const OtpVerificationState();
  }
}

final otpVerificationProvider =
    NotifierProvider<OtpVerificationNotifier, OtpVerificationState>(
      OtpVerificationNotifier.new,
    );

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);
