// ignore_for_file: use_null_aware_elements

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eikhatib/core/api/dio_consumer.dart';
import 'package:eikhatib/core/api/end_point.dart';
import 'package:eikhatib/core/errors/exception.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/auth_credential_storage.dart';
import '../data/models/user_model.dart';

class UserState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool requiresOtpVerification;
  final File? logoImage;
  final bool hasOnboarded;
  final bool isReady;
  final String? registeredPhone;
  final String? registeredName;
  final String? status;

  const UserState({
    this.user,
    this.logoImage,
    this.isLoading = false,
    this.error,
    this.requiresOtpVerification = false,
    this.hasOnboarded = false,
    this.isReady = false,
    this.registeredPhone,
    this.registeredName,
    this.status,
  });

  UserState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? requiresOtpVerification,
    bool? hasOnboarded,
    bool? isReady,
    File? logoImage,
    String? registeredPhone,
    String? registeredName,
    String? status,
    bool clearError = false,
    bool clearFlags = false,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      requiresOtpVerification: clearFlags
          ? false
          : (requiresOtpVerification ?? this.requiresOtpVerification),
      hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      isReady: isReady ?? this.isReady,
      logoImage: logoImage ?? this.logoImage,
      registeredPhone: registeredPhone ?? this.registeredPhone,
      registeredName: registeredName ?? this.registeredName,
      status: status ?? this.status,
    );
  }
}

class UserCubit extends Cubit<UserState> {
  final DioConsumer apiConsumer = DioConsumer(dio: Dio());
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final AuthCredentialStorage credentialStorage = AuthCredentialStorage();

  UserCubit() : super(const UserState()) {
    checkLoggedInStatus();
  }

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token format');
    }
    String normalizedSource = base64Url.normalize(parts[1]);
    final payloadString = utf8.decode(base64Url.decode(normalizedSource));
    return json.decode(payloadString) as Map<String, dynamic>;
  }

  Future<void> checkLoggedInStatus() async {
    final token = await secureStorage.read(key: 'token');
    if (token != null) {
      try {
        final response = await apiConsumer.get(EndPoint.getProfile);
        final userObj = UserModel.fromJson(response);
        emit(state.copyWith(user: userObj));
      } catch (e) {
        // Only delete token if it is explicitly an authentication error (401 or 403)
        // Keep the session alive for network errors or server 500 errors.
        bool shouldDeleteToken = true;
        
        if (e is ServerException) {
          final code = e.statusCode;
          if (code != null && code != 401 && code != 403) {
            shouldDeleteToken = false;
          }
        } else if (e is DioException) {
          final code = e.response?.statusCode;
          if (code != null && code != 401 && code != 403) {
            shouldDeleteToken = false;
          } else if (e.type != DioExceptionType.badResponse) {
            // It's a timeout or connection issue, not an authentication failure
            shouldDeleteToken = false;
          }
        } else {
          // Any other error (unrecognized local error) should not trigger auto-logout
          shouldDeleteToken = false;
        }

        if (shouldDeleteToken) {
          await secureStorage.delete(key: 'token');
          await secureStorage.delete(key: 'refresh_token');
          emit(state.copyWith(user: null));
        } else {
          // Network issue or server downtime: Decode the token locally to keep user session alive
          try {
            final payload = _decodeJwt(token);
            final userObj = UserModel(
              id: payload['id']?.toString() ?? '',
              name: payload['name'] ?? payload['phone_number'] ?? 'مستخدم',
              phoneNumber: payload['phone_number'],
              role: payload['role'] ?? 'user',
              isApproved: true, // Assume approved if they have a valid token
            );
            emit(state.copyWith(user: userObj));
          } catch (_) {
            // Failed to decode token payload, treat token as corrupt and log out
            await secureStorage.delete(key: 'token');
            await secureStorage.delete(key: 'refresh_token');
            emit(state.copyWith(user: null));
          }
        }
      }
    } else {
      // Check for pending OTP
      final isPending = await secureStorage.read(key: 'is_pending_otp');
      if (isPending == 'true') {
        final phone = await secureStorage.read(key: 'pending_phone');
        final name = await secureStorage.read(key: 'pending_name');
        emit(
          state.copyWith(
            requiresOtpVerification: true,
            registeredPhone: phone,
            registeredName: name,
          ),
        );
      }
    }

    // Check onboarding status
    final hasSeenOnboarding = await secureStorage.read(
      key: 'has_seen_onboarding',
    );

    emit(
      state.copyWith(hasOnboarded: hasSeenOnboarding == 'true', isReady: true),
    );
  }

  Future<void> getProfile() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final response = await apiConsumer.get(EndPoint.getProfile);
      final userObj = UserModel.fromJson(response);
      emit(state.copyWith(isLoading: false, user: userObj));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'فشل تحديث البيانات'));
    }
  }

  Future<void> completeOnboarding() async {
    await secureStorage.write(key: 'has_seen_onboarding', value: 'true');
    emit(state.copyWith(hasOnboarded: true));
  }

  Future<void> login(String phone, String password, {bool rememberMe = false}) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearFlags: true));
    try {
      final response = await apiConsumer.post(
        EndPoint.login,
        data: {'phone_number': phone, 'password': password},
      );

      final userObj = UserModel.fromJson(response['user']);
      final token = response['token'];
      final refreshToken = response['refreshToken'];

      await secureStorage.write(key: 'token', value: token);
      if (refreshToken != null) {
        await secureStorage.write(key: 'refresh_token', value: refreshToken);
      }
      await credentialStorage.saveLoginCredentials(
        rememberMe: rememberMe,
        phone: phone,
        password: password,
      );

      emit(
        state.copyWith(
          isLoading: false,
          user: userObj,
          requiresOtpVerification: false,
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          e.response?.data['requires_approval'] == true) {
        emit(
          state.copyWith(
            isLoading: false,
            status: 'waiting_approval',
            error: e.response?.data['message'] ?? 'الحساب بانتظار موافقة الإدارة',
          ),
        );
      } else if (e.response?.statusCode == 403 &&
          e.response?.data['requires_otp'] == true) {
        emit(
          state.copyWith(
            isLoading: false,
            requiresOtpVerification: true,
            registeredPhone: phone,
            error: e.response?.data['message'] ?? 'الحساب غير مفعل',
          ),
        );
        await secureStorage.write(key: 'is_pending_otp', value: 'true');
        await secureStorage.write(key: 'pending_phone', value: phone);
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            error: e.response?.data['message'] ?? 'فشل تسجيل الدخول',
          ),
        );
      }
    } on ServerException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.errorModel.errorMessage));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'حدث خطأ غير معروف'));
    }
  }

  Future<void> register({
    required String storeName,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    String role = 'user',
    File? logoImage,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearFlags: true));
    try {
      final response = await apiConsumer.post(
        EndPoint.register,
        isFromData: true,
        data: {
          'name': storeName,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phone,
          if (logoImage != null)
            'logo': await MultipartFile.fromFile(logoImage.path),
          'password': password,
          'role': role,
        },
      );

      if (response['requires_approval'] == true) {
        emit(
          state.copyWith(
            isLoading: false,
            status: 'waiting_approval',
            registeredPhone: phone,
            registeredName: storeName,
            logoImage: logoImage,
          ),
        );
      } else if (response['requires_otp'] == true) {
        emit(
          state.copyWith(
            isLoading: false,
            requiresOtpVerification: true,
            registeredPhone: phone,
            registeredName: storeName,
            logoImage: logoImage,
          ),
        );
        await secureStorage.write(key: 'is_pending_otp', value: 'true');
        await secureStorage.write(key: 'pending_phone', value: phone);
        await secureStorage.write(key: 'pending_name', value: storeName);
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } on DioException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.response?.data['message'] ?? 'فشل التسجيل',
        ),
      );
    } on ServerException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.errorModel.errorMessage));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'حدث خطأ غير معروف'));
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final response = await apiConsumer.post(
        EndPoint.verifyOtp,
        data: {'phone_number': phone, 'otp': otp},
      );

      final userObj = UserModel.fromJson(response['user']);
      final token = response['token'];
      final refreshToken = response['refreshToken'];

      await secureStorage.write(key: 'token', value: token);
      if (refreshToken != null) {
        await secureStorage.write(key: 'refresh_token', value: refreshToken);
      }

      await secureStorage.delete(key: 'is_pending_otp');
      await secureStorage.delete(key: 'pending_phone');
      await secureStorage.delete(key: 'pending_name');

      emit(
        state.copyWith(
          isLoading: false,
          user: userObj,
          requiresOtpVerification: false,
        ),
      );
    } on DioException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.response?.data['message'] ?? 'فشل التحقق',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'حدث خطأ غير معروف'));
    }
  }

  Future<void> resendOtp(String phone) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await apiConsumer.post(
        EndPoint.resendOtp,
        data: {'phone_number': phone},
      );
      emit(state.copyWith(isLoading: false));
    } on DioException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.response?.data['message'] ?? 'فشل إعادة الإرسال',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'حدث خطأ غير معروف'));
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      if (refreshToken != null) {
        await apiConsumer.post(
          EndPoint.logout,
          data: {'refresh_token': refreshToken},
        );
      }
    } catch (_) {}
    await secureStorage.delete(key: 'token');
    await secureStorage.delete(key: 'refresh_token');
    await secureStorage.delete(key: 'is_pending_otp');
    await secureStorage.delete(key: 'pending_phone');
    await secureStorage.delete(key: 'pending_name');
    emit(const UserState());
  }

  Future<bool> deleteAccount() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await apiConsumer.delete(EndPoint.deleteAccount);
      await secureStorage.deleteAll();
      await credentialStorage.clearCredentials();
      emit(const UserState());
      return true;
    } catch (e) {
      String errMsg = 'فشل حذف الحساب، يرجى المحاولة لاحقاً';
      if (e is DioException && e.response?.data is Map && e.response?.data['message'] != null) {
        errMsg = e.response!.data['message'];
      }
      emit(state.copyWith(isLoading: false, error: errMsg));
      return false;
    }
  }

  Future<void> updateProfile({
    String? storeName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    if (state.user == null) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      String? normalizedPhone;
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        final cleanPhone = phoneNumber.trim().startsWith('0')
            ? phoneNumber.trim().substring(1)
            : phoneNumber.trim();
        normalizedPhone = '+962$cleanPhone';
      }

      final response = await apiConsumer.put(
        'auth/profile',
        data: {
          if (storeName != null) 'name': storeName,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (normalizedPhone != null) 'phone_number': normalizedPhone,
        },
      );

      final updatedUser = UserModel.fromJson(response['user']);
      emit(state.copyWith(isLoading: false, user: updatedUser));
    } on DioException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.response?.data['message'] ?? 'فشل تحديث البيانات',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'حدث خطأ غير معروف'));
    }
  }

  // Deprecated: used for local testing, use updateProfile instead
  void updateUserInfo(String firstName, String lastName) {
    if (state.user == null) return;
    final updatedUser = state.user!.copyWith(
      firstName: firstName,
      lastName: lastName,
      name: '$firstName $lastName',
    );
    emit(state.copyWith(user: updatedUser));
  }

  Future<void> forgotPassword(String phone) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await apiConsumer.post(
        EndPoint.forgotPassword,
        data: {'phone_number': phone},
      );
      emit(state.copyWith(isLoading: false));
    } on DioException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.response?.data['message'] ?? 'فشل إرسال رمز التحقق',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'حدث خطأ غير معروف'));
    }
  }

  Future<String> checkResetStatus(String phone) async {
    try {
      final response = await apiConsumer.get(
        EndPoint.resetStatus,
        queryParameters: {'phone_number': phone},
      );
      return response['status'] ?? 'none';
    } catch (_) {
      return 'none';
    }
  }

  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await apiConsumer.post(
        EndPoint.resetPassword,
        data: {'phone_number': phone, 'otp': otp, 'password': newPassword},
      );
      emit(state.copyWith(isLoading: false));
    } on DioException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.response?.data['message'] ?? 'فشل إعادة تعيين كلمة المرور',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'حدث خطأ غير معروف'));
    }
  }

  // ── Upload Driver Documents (Dual-Sided) ──────────────────────────────────
  Future<void> uploadDriverDocuments({
    required File idFront,
    required File idBack,
    required File licenseFront,
    required File licenseBack,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final formData = FormData.fromMap({
        'id_front': await MultipartFile.fromFile(
          idFront.path,
          filename: 'id_front.jpg',
        ),
        'id_back': await MultipartFile.fromFile(
          idBack.path,
          filename: 'id_back.jpg',
        ),
        'license_front': await MultipartFile.fromFile(
          licenseFront.path,
          filename: 'license_front.jpg',
        ),
        'license_back': await MultipartFile.fromFile(
          licenseBack.path,
          filename: 'license_back.jpg',
        ),
      });

      await apiConsumer.post(EndPoint.uploadDriverDocuments, data: formData);

      emit(state.copyWith(isLoading: false, status: 'pending_approval'));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'فشل رفع الوثائق'));
    }
  }

  bool get isLoggedIn => state.user != null;
}
