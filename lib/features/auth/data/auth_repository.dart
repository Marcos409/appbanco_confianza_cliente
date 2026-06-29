import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/cliente_model.dart';

class AuthRepository {
  final Dio _dio;
  final SecureStorage _storage;

  AuthRepository()
      : _dio = ApiClient.instance.dio,
        _storage = SecureStorage.instance;

  Future<RegistroResponse> register({
    required String numeroDocumento,
    required String nombres,
    required String apellidos,
    required DateTime fechaNacimiento,
    required String estadoCivil,
    required String email,
    required String telefono,
    required String direccion,
    required String password,
    required bool aceptoTerminos,
  }) async {
    debugPrint('[AuthRepo] register() llamado - documento: $numeroDocumento');
    try {
      final fechaStr = '${fechaNacimiento.year.toString().padLeft(4, '0')}-'
          '${fechaNacimiento.month.toString().padLeft(2, '0')}-'
          '${fechaNacimiento.day.toString().padLeft(2, '0')}';
      final response = await _dio.post('/cliente/registrar', data: {
        'numero_documento': numeroDocumento,
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaStr,
        'estado_civil': estadoCivil,
        'email': email,
        'telefono': telefono,
        'direccion': direccion,
        'password': password,
        'acepto_terminos': aceptoTerminos,
      });
      debugPrint('[AuthRepo] register() exitoso - status: ${response.statusCode}');
      return RegistroResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[AuthRepo] register() falló - error: $e');
      rethrow;
    }
  }

  Future<LoginResponse> login(String documento, String password) async {
    debugPrint('[AuthRepo] login() llamado - documento: $documento');
    try {
      final response = await _dio.post('/cliente/login', data: {
        'numero_documento': documento,
        'password': password,
      });
      debugPrint('[AuthRepo] login() response - status: ${response.statusCode}');
      final data = response.data as Map<String, dynamic>;
      debugPrint('[AuthRepo] login() data recibida - keys: ${data.keys}');
      final loginResp = LoginResponse.fromJson(data);
      debugPrint('[AuthRepo] login() token recibido: ${loginResp.accessToken.substring(0, 20)}...');
      await _storage.saveToken(loginResp.accessToken);
      debugPrint('[AuthRepo] login() token guardado en SecureStorage');
      await _storage.saveClienteData(data['cliente'].toString());
      debugPrint('[AuthRepo] login() datos cliente guardados en SecureStorage');
      return loginResp;
    } on DioException catch (e) {
      debugPrint('[AuthRepo] login() DioException - status: ${e.response?.statusCode}, '
          'body: ${e.response?.data}, message: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AuthRepo] login() error inesperado: $e');
      rethrow;
    }
  }

  Future<ClienteModel> getPerfil() async {
    final response = await _dio.get('/cliente/perfil');
    return ClienteModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> hasSession() async {
    return await _storage.hasSession();
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }
}
