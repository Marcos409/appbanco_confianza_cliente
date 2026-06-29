import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class NotificacionModel {
  final String id;
  final String titulo;
  final String? cuerpo;
  final String? tipo;
  final bool leida;
  final String createdAt;

  const NotificacionModel({
    required this.id, required this.titulo, this.cuerpo,
    this.tipo, this.leida = false, required this.createdAt,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) => NotificacionModel(
    id: json['id']?.toString() ?? '',
    titulo: json['titulo']?.toString() ?? '',
    cuerpo: json['cuerpo']?.toString(),
    tipo: json['tipo']?.toString(),
    leida: json['leida'] ?? false,
    createdAt: json['created_at']?.toString() ?? '',
  );
}

class NotificacionesRepository {
  final Dio _dio;

  NotificacionesRepository() : _dio = ApiClient.instance.dio;

  Future<List<NotificacionModel>> getNotificaciones() async {
    final response = await _dio.get('/cliente/notificaciones');
    final list = response.data as List<dynamic>;
    return list.map((e) => NotificacionModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
