import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../domain/solicitud_model.dart';

class SolicitudesRepository {
  final Dio _dio;

  SolicitudesRepository() : _dio = ApiClient.instance.dio;

  Future<SolicitudCreadaResponse> crearSolicitud(Map<String, dynamic> data) async {
    final response = await _dio.post('/cliente/solicitudes', data: data);
    return SolicitudCreadaResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<SolicitudModel>> listarSolicitudes() async {
    final response = await _dio.get('/cliente/solicitudes');
    final list = response.data as List<dynamic>;
    return list.map((e) => SolicitudModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SolicitudDetalleModel> obtenerSolicitud(String id) async {
    final response = await _dio.get('/cliente/solicitudes/$id');
    return SolicitudDetalleModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> firmarSolicitud(String id, {String? firmaBase64}) async {
    final body = <String, dynamic>{};
    if (firmaBase64 != null) body['firma_base64'] = firmaBase64;
    final response = await _dio.put('/cliente/solicitudes/$id/firmar', data: body);
    return response.data as Map<String, dynamic>;
  }
}
