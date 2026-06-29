import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _tokenKey = 'access_token';
  static const _clienteDataKey = 'cliente_data';

  static final SecureStorage _instance = SecureStorage._();
  static SecureStorage get instance => _instance;

  final FlutterSecureStorage _storage;

  SecureStorage._() : _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveClienteData(String data) async {
    await _storage.write(key: _clienteDataKey, value: data);
  }

  Future<String?> getClienteData() async {
    return await _storage.read(key: _clienteDataKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<bool> hasSession() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }
}
