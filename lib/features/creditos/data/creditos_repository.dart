import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class CreditoModel {
  final String id;
  final String codCuentaCredito;
  final String? producto;
  final double? montoDesembolsado;
  final double? saldoCapital;
  final double? saldoTotal;
  final int diasMora;
  final String? calificacionInterna;
  final String? estado;
  final String? fechaDesembolso;
  final double? tea;
  final int? cuotasTotal;
  final int? cuotasPagadas;

  const CreditoModel({
    required this.id,
    required this.codCuentaCredito,
    this.producto, this.montoDesembolsado, this.saldoCapital,
    this.saldoTotal, this.diasMora = 0, this.calificacionInterna,
    this.estado, this.fechaDesembolso, this.tea,
    this.cuotasTotal, this.cuotasPagadas,
  });

  factory CreditoModel.fromJson(Map<String, dynamic> json) => CreditoModel(
    id: json['id']?.toString() ?? '',
    codCuentaCredito: json['cod_cuenta_credito']?.toString() ?? '',
    producto: json['producto']?.toString(),
    montoDesembolsado: (json['monto_desembolsado'] ?? 0).toDouble(),
    saldoCapital: (json['saldo_capital'] ?? 0).toDouble(),
    saldoTotal: (json['saldo_total'] ?? 0).toDouble(),
    diasMora: json['dias_mora'] ?? 0,
    calificacionInterna: json['calificacion_interna']?.toString(),
    estado: json['estado']?.toString(),
    fechaDesembolso: json['fecha_desembolso']?.toString(),
    tea: (json['tea'] ?? 0).toDouble(),
    cuotasTotal: json['cuotas_total'],
    cuotasPagadas: json['cuotas_pagadas'],
  );
}

class CuotaModel {
  final String id;
  final String codCuentaCredito;
  final int nroCuota;
  final String fechaVencimiento;
  final double? montoCuota;
  final double? montoCapital;
  final double? montoInteres;
  final double? saldo;
  final String? estadoCuota;
  final String? fechaPago;

  const CuotaModel({
    required this.id, required this.codCuentaCredito, required this.nroCuota,
    required this.fechaVencimiento, this.montoCuota, this.montoCapital,
    this.montoInteres, this.saldo, this.estadoCuota, this.fechaPago,
  });

  factory CuotaModel.fromJson(Map<String, dynamic> json) => CuotaModel(
    id: json['id']?.toString() ?? '',
    codCuentaCredito: json['cod_cuenta_credito']?.toString() ?? '',
    nroCuota: json['nro_cuota'] ?? 0,
    fechaVencimiento: json['fecha_vencimiento']?.toString() ?? '',
    montoCuota: (json['monto_cuota'] ?? 0).toDouble(),
    montoCapital: (json['monto_capital'] ?? 0).toDouble(),
    montoInteres: (json['monto_interes'] ?? 0).toDouble(),
    saldo: (json['saldo'] ?? 0).toDouble(),
    estadoCuota: json['estado_cuota']?.toString(),
    fechaPago: json['fecha_pago']?.toString(),
  );
}

class CreditosRepository {
  final Dio _dio;

  CreditosRepository() : _dio = ApiClient.instance.dio;

  Future<List<CreditoModel>> getCreditos() async {
    final response = await _dio.get('/cliente/creditos');
    final list = response.data as List<dynamic>;
    return list.map((e) => CreditoModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CuotaModel>> getCronograma(String codCuentaCredito) async {
    final response = await _dio.get('/cliente/creditos/$codCuentaCredito/cronograma');
    final list = response.data as List<dynamic>;
    return list.map((e) => CuotaModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
