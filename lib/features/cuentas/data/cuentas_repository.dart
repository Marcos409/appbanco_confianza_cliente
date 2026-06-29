import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class CuentaModel {
  final String id;
  final String codCuentaAhorro;
  final String? tipoCuenta;
  final String? moneda;
  final double? saldoCapital;
  final double? saldoInteres;
  final double? tea;
  final String? estado;

  const CuentaModel({
    required this.id,
    required this.codCuentaAhorro,
    this.tipoCuenta,
    this.moneda,
    this.saldoCapital,
    this.saldoInteres,
    this.tea,
    this.estado,
  });

  factory CuentaModel.fromJson(Map<String, dynamic> json) => CuentaModel(
    id: json['id']?.toString() ?? '',
    codCuentaAhorro: json['cod_cuenta_ahorro']?.toString() ?? '',
    tipoCuenta: json['tipo_cuenta']?.toString(),
    moneda: json['moneda']?.toString(),
    saldoCapital: (json['saldo_capital'] ?? 0).toDouble(),
    saldoInteres: (json['saldo_interes'] ?? 0).toDouble(),
    tea: (json['tea'] ?? 0).toDouble(),
    estado: json['estado']?.toString(),
  );
}

class CuentasRepository {
  final Dio _dio;

  CuentasRepository() : _dio = ApiClient.instance.dio;

  Future<List<CuentaModel>> getCuentas() async {
    final response = await _dio.get('/cliente/cuentas');
    final list = response.data as List<dynamic>;
    return list.map((e) => CuentaModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
