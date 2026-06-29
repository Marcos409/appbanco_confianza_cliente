import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class PerfilRepository {
  final Dio _dio;

  PerfilRepository() : _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getPerfil() async {
    final response = await _dio.get('/cliente/perfil');
    return response.data as Map<String, dynamic>;
  }
}
