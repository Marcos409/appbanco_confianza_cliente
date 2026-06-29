import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class CuentaOrigen {
  final String codCuenta;
  final double saldo;

  const CuentaOrigen({required this.codCuenta, required this.saldo});

  factory CuentaOrigen.fromJson(Map<String, dynamic> json) => CuentaOrigen(
    codCuenta: json['cod_cuenta_ahorro']?.toString() ?? '',
    saldo: (json['saldo_capital'] ?? 0).toDouble(),
  );
}

class CreditoDestino {
  final String codCuentaCredito;
  final String? producto;
  final double? saldoTotal;
  final double? montoCuota;

  const CreditoDestino({
    required this.codCuentaCredito, this.producto,
    this.saldoTotal, this.montoCuota,
  });

  factory CreditoDestino.fromJson(Map<String, dynamic> json) => CreditoDestino(
    codCuentaCredito: json['cod_cuenta_credito']?.toString() ?? '',
    producto: json['producto']?.toString(),
    saldoTotal: (json['saldo_total'] ?? 0).toDouble(),
    montoCuota: (json['monto_cuota'] ?? 0).toDouble(),
  );
}

class PagosRepository {
  final Dio _dio;

  PagosRepository() : _dio = ApiClient.instance.dio;

  Future<List<CuentaOrigen>> getCuentasOrigen() async {
    final response = await _dio.get('/cliente/cuentas');
    final list = response.data as List<dynamic>;
    return list.map((e) => CuentaOrigen.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CreditoDestino> getCreditoInfo(String codCuentaCredito) async {
    final response = await _dio.get('/cliente/creditos');
    final list = response.data as List<dynamic>;
    for (final c in list) {
      final m = c as Map<String, dynamic>;
      if (m['cod_cuenta_credito'] == codCuentaCredito) {
        final crono = await _dio.get('/cliente/creditos/$codCuentaCredito/cronograma');
        final cuotas = crono.data as List<dynamic>;
        double? montoCuota;
        for (final cuota in cuotas) {
          final cm = cuota as Map<String, dynamic>;
          if (cm['estado_cuota']?.toString().toLowerCase() != 'pagada' && cm['fecha_pago'] == null) {
            montoCuota = (cm['monto_cuota'] ?? 0).toDouble();
            break;
          }
        }
        return CreditoDestino(
          codCuentaCredito: codCuentaCredito,
          producto: m['producto']?.toString(),
          saldoTotal: (m['saldo_total'] ?? 0).toDouble(),
          montoCuota: montoCuota,
        );
      }
    }
    throw Exception('Crédito no encontrado');
  }

  Future<Map<String, dynamic>> realizarPago({
    required String cuentaOrigen,
    required String creditoDestino,
    required double monto,
  }) async {
    final response = await _dio.post('/cliente/operaciones', data: {
      'cod_cuenta_origen': cuentaOrigen,
      'cod_cuenta_destino': creditoDestino,
      'tipo': 'pago_cuota',
      'monto': monto,
      'moneda': 'PEN',
    });
    return response.data as Map<String, dynamic>;
  }
}
