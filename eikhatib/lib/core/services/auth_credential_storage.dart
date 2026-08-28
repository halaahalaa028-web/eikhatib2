import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class CredentialStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureCredentialStorage implements CredentialStorage {
  final FlutterSecureStorage secureStorage;

  const FlutterSecureCredentialStorage({required this.secureStorage});

  @override
  Future<String?> read(String key) => secureStorage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      secureStorage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => secureStorage.delete(key: key);
}

class AuthCredentialStorage {
  static const String rememberMeKey = 'remember_me';
  static const String savedPhoneKey = 'saved_phone';
  static const String savedPasswordKey = 'saved_password';

  final CredentialStorage _storage;

  AuthCredentialStorage({CredentialStorage? storage})
    : _storage = storage ??
          const FlutterSecureCredentialStorage(
            secureStorage: FlutterSecureStorage(),
          );

  Future<void> saveLoginCredentials({
    required bool rememberMe,
    String? phone,
    String? password,
  }) async {
    if (rememberMe &&
        phone != null &&
        phone.trim().isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      await _storage.write(rememberMeKey, 'true');
      await _storage.write(savedPhoneKey, phone.trim());
      await _storage.write(savedPasswordKey, password);
      return;
    }

    await _storage.delete(rememberMeKey);
    await _storage.delete(savedPhoneKey);
    await _storage.delete(savedPasswordKey);
  }

  Future<Map<String, dynamic>> loadLoginCredentials() async {
    final rememberMe = await _storage.read(rememberMeKey) == 'true';
    if (!rememberMe) {
      return {'rememberMe': false, 'phone': null, 'password': null};
    }

    final phone = await _storage.read(savedPhoneKey);
    final password = await _storage.read(savedPasswordKey);

    return {
      'rememberMe': true,
      'phone': phone,
      'password': password,
    };
  }

  Future<void> clearCredentials() async {
    await _storage.delete(rememberMeKey);
    await _storage.delete(savedPhoneKey);
    await _storage.delete(savedPasswordKey);
  }
}
