import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class MovimientoModel {
  final String id;
  final String codOperacion;
  final String? codCuenta;
  final String? tipo;
  final String? concepto;
  final String? canal;
  final double monto;
  final String? moneda;
  final String fechaOperacion;

  const MovimientoModel({
    required this.id, required this.codOperacion, this.codCuenta,
    this.tipo, this.concepto, this.canal, required this.monto,
    this.moneda, required this.fechaOperacion,
  });

  factory MovimientoModel.fromJson(Map<String, dynamic> json) => MovimientoModel(
    id: json['id']?.toString() ?? '',
    codOperacion: json['cod_operacion']?.toString() ?? '',
    codCuenta: json['cod_cuenta']?.toString(),
    tipo: json['tipo']?.toString(),
    concepto: json['concepto']?.toString(),
    canal: json['canal']?.toString(),
    monto: (json['monto'] ?? 0).toDouble(),
    moneda: json['moneda']?.toString(),
    fechaOperacion: json['fecha_operacion']?.toString() ?? '',
  );
}

class MovimientosRepository {
  final Dio _dio;

  MovimientosRepository() : _dio = ApiClient.instance.dio;

  Future<List<MovimientoModel>> getMovimientos({int limit = 30}) async {
    final response = await _dio.get('/cliente/movimientos', queryParameters: {'limit': limit});
    final list = response.data as List<dynamic>;
    return list.map((e) => MovimientoModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
