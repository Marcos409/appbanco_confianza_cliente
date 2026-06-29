import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class DashboardResumen {
  final double saldoTotal;
  final double deudaTotal;
  final int totalCuentas;
  final int totalCreditos;

  const DashboardResumen({
    required this.saldoTotal,
    required this.deudaTotal,
    required this.totalCuentas,
    required this.totalCreditos,
  });

  factory DashboardResumen.fromJson(Map<String, dynamic> json) => DashboardResumen(
    saldoTotal: (json['saldo_total'] ?? 0).toDouble(),
    deudaTotal: (json['deuda_total'] ?? 0).toDouble(),
    totalCuentas: json['total_cuentas'] ?? 0,
    totalCreditos: json['total_creditos'] ?? 0,
  );
}

class DashboardRepository {
  final Dio _dio;

  DashboardRepository() : _dio = ApiClient.instance.dio;

  Future<DashboardResumen> getResumen() async {
    final cuentas = await _dio.get('/cliente/cuentas');
    final creditos = await _dio.get('/cliente/creditos');
    final cuentasList = cuentas.data as List<dynamic>;
    final creditosList = creditos.data as List<dynamic>;

    double saldoTotal = 0;
    for (final c in cuentasList) {
      saldoTotal += (c['saldo_capital'] ?? 0).toDouble();
    }

    double deudaTotal = 0;
    for (final c in creditosList) {
      deudaTotal += (c['saldo_total'] ?? 0).toDouble();
    }

    return DashboardResumen(
      saldoTotal: saldoTotal,
      deudaTotal: deudaTotal,
      totalCuentas: cuentasList.length,
      totalCreditos: creditosList.length,
    );
  }
}
