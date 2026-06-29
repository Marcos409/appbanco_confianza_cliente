class SolicitudModel {
  final String id;
  final String? numeroExpediente;
  final double montoSolicitado;
  final String moneda;
  final String estado;
  final String? createdAt;

  const SolicitudModel({
    required this.id,
    this.numeroExpediente,
    required this.montoSolicitado,
    this.moneda = 'PEN',
    required this.estado,
    this.createdAt,
  });

  String get montoFormateado => 'S/ ${montoSolicitado.toStringAsFixed(2)}';

  factory SolicitudModel.fromJson(Map<String, dynamic> json) => SolicitudModel(
    id: json['id']?.toString() ?? '',
    numeroExpediente: json['numero_expediente']?.toString(),
    montoSolicitado: (json['monto_solicitado'] as num?)?.toDouble() ?? 0,
    moneda: json['moneda']?.toString() ?? 'PEN',
    estado: json['estado']?.toString() ?? '',
    createdAt: json['created_at']?.toString(),
  );
}

class SolicitudDetalleModel {
  final String id;
  final String? numeroExpediente;
  final String clienteNombre;
  final double montoSolicitado;
  final double? montoAprobado;
  final int plazoMeses;
  final String moneda;
  final String tipoCuota;
  final String garantia;
  final String? destinoCredito;
  final String estado;
  final String? motivoRechazo;
  final String? condicionAdicional;
  final String? createdAt;
  final String? updatedAt;

  const SolicitudDetalleModel({
    required this.id,
    this.numeroExpediente,
    this.clienteNombre = '',
    required this.montoSolicitado,
    this.montoAprobado,
    this.plazoMeses = 0,
    this.moneda = 'PEN',
    this.tipoCuota = 'mensual',
    this.garantia = 'sin_garantia',
    this.destinoCredito,
    required this.estado,
    this.motivoRechazo,
    this.condicionAdicional,
    this.createdAt,
    this.updatedAt,
  });

  String get montoFormateado => 'S/ ${montoSolicitado.toStringAsFixed(2)}';
  String get montoAprobadoFormateado =>
      montoAprobado != null ? 'S/ ${montoAprobado!.toStringAsFixed(2)}' : '—';

  factory SolicitudDetalleModel.fromJson(Map<String, dynamic> json) =>
      SolicitudDetalleModel(
        id: json['id']?.toString() ?? '',
        numeroExpediente: json['numero_expediente']?.toString(),
        clienteNombre: json['cliente_nombre']?.toString() ?? '',
        montoSolicitado: (json['monto_solicitado'] as num?)?.toDouble() ?? 0,
        montoAprobado: (json['monto_aprobado'] as num?)?.toDouble(),
        plazoMeses: (json['plazo_meses'] as num?)?.toInt() ?? 0,
        moneda: json['moneda']?.toString() ?? 'PEN',
        tipoCuota: json['tipo_cuota']?.toString() ?? 'mensual',
        garantia: json['garantia']?.toString() ?? 'sin_garantia',
        destinoCredito: json['destino_credito']?.toString(),
        estado: json['estado']?.toString() ?? '',
        motivoRechazo: json['motivo_rechazo']?.toString(),
        condicionAdicional: json['condicion_adicional']?.toString(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );
}

class SolicitudCreadaResponse {
  final String id;
  final String numeroExpediente;
  final String estado;

  const SolicitudCreadaResponse({
    required this.id,
    required this.numeroExpediente,
    required this.estado,
  });

  factory SolicitudCreadaResponse.fromJson(Map<String, dynamic> json) =>
      SolicitudCreadaResponse(
        id: json['id']?.toString() ?? '',
        numeroExpediente: json['numero_expediente']?.toString() ?? '',
        estado: json['estado']?.toString() ?? '',
      );
}
