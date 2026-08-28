import 'package:dio/dio.dart';
import 'package:eikhatib/core/api/dio_consumer.dart';
import 'package:eikhatib/core/api/end_point.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityState {
  final bool is2FAEnabled;
  final bool isBiometricsEnabled;
  final bool isDeviceSupported;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const SecurityState({
    this.is2FAEnabled = false,
    this.isBiometricsEnabled = false,
    this.isDeviceSupported = false,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  SecurityState copyWith({
    bool? is2FAEnabled,
    bool? isBiometricsEnabled,
    bool? isDeviceSupported,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return SecurityState(
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      isDeviceSupported: isDeviceSupported ?? this.isDeviceSupported,
      isLoading: isLoading ?? this.isLoading,
      error: clearMessages ? null : (error ?? this.error),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

class SecurityCubit extends Cubit<SecurityState> {
  final LocalAuthentication _auth = LocalAuthentication();
  final DioConsumer apiConsumer = DioConsumer(dio: Dio());
  late SharedPreferences _prefs;

  SecurityCubit() : super(const SecurityState()) {
    _init();
  }

  Future<void> _init() async {
    emit(state.copyWith(isLoading: true));
    _prefs = await SharedPreferences.getInstance();
    
    final isSupported = await _auth.isDeviceSupported();
    final canCheckBiometrics = await _auth.canCheckBiometrics;
    
    final saved2FA = _prefs.getBool('2fa_enabled') ?? false;
    final savedBiometrics = _prefs.getBool('biometrics_enabled') ?? false;

    emit(state.copyWith(
      isLoading: false,
      isDeviceSupported: isSupported && canCheckBiometrics,
      is2FAEnabled: saved2FA,
      isBiometricsEnabled: savedBiometrics,
    ));
  }

  // ── 2FA REAL INTEGRATION ──────────────────────────────────────────────────

  Future<void> toggle2FA(bool value) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final response = await apiConsumer.patch(
        EndPoint.toggle2FA,
        data: {'enabled': value},
      );
      await _prefs.setBool('2fa_enabled', value);
      emit(state.copyWith(
        isLoading: false,
        is2FAEnabled: value,
        successMessage: response['message'],
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل تحديث إعدادات المصادقة الثنائية',
      ));
    }
  }

  Future<bool> sendSecureOtp() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      await apiConsumer.post(EndPoint.sendOtpSecure);
      emit(state.copyWith(isLoading: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'فشل إرسال رمز التحقق'));
      return false;
    }
  }

  Future<bool> verifySecureOtp(String otp) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      await apiConsumer.post(
        EndPoint.verifyOtpSecure,
        data: {'otp': otp},
      );
      emit(state.copyWith(isLoading: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'رمز التحقق غير صحيح أو منتهي الصلاحية',
      ));
      return false;
    }
  }

  // ── BIOMETRICS ──────────────────────────────────────────────────────────

  Future<bool> toggleBiometrics(bool value) async {
    if (value) {
      final success = await authenticate();
      if (success) {
        await _prefs.setBool('biometrics_enabled', true);
        emit(state.copyWith(isBiometricsEnabled: true));
        return true;
      }
      return false;
    } else {
      await _prefs.setBool('biometrics_enabled', false);
      emit(state.copyWith(isBiometricsEnabled: false));
      return true;
    }
  }

  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'الرجاء التحقق من هويتك للمتابعة',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      emit(state.copyWith(error: 'فشل التحقق من البصمة'));
      return false;
    }
  }
}
