class ClienteModel {
  final String id;
  final String numeroDocumento;
  final String nombres;
  final String apellidos;
  final String? fechaNacimiento;
  final String? estadoCivil;
  final String? email;
  final String? telefono;
  final String? direccion;
  final String? codCliente;

  const ClienteModel({
    required this.id,
    required this.numeroDocumento,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    this.estadoCivil,
    this.email,
    this.telefono,
    this.direccion,
    this.codCliente,
  });

  String get nombreCompleto => '$nombres $apellidos';

  factory ClienteModel.fromJson(Map<String, dynamic> json) => ClienteModel(
    id: json['id']?.toString() ?? '',
    numeroDocumento: json['numero_documento']?.toString() ?? '',
    nombres: json['nombres']?.toString() ?? '',
    apellidos: json['apellidos']?.toString() ?? '',
    fechaNacimiento: json['fecha_nacimiento']?.toString(),
    estadoCivil: json['estado_civil']?.toString(),
    email: json['email']?.toString(),
    telefono: json['telefono']?.toString(),
    direccion: json['direccion']?.toString(),
    codCliente: json['cod_cliente']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'numero_documento': numeroDocumento,
    'nombres': nombres,
    'apellidos': apellidos,
    'fecha_nacimiento': fechaNacimiento,
    'estado_civil': estadoCivil,
    'email': email,
    'telefono': telefono,
    'direccion': direccion,
    'cod_cliente': codCliente,
  };
}

class RegistroResponse {
  final String status;
  final String message;

  const RegistroResponse({required this.status, required this.message});

  factory RegistroResponse.fromJson(Map<String, dynamic> json) => RegistroResponse(
    status: json['status']?.toString() ?? '',
    message: json['message']?.toString() ?? '',
  );
}

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final ClienteModel cliente;

  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.cliente,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json['access_token']?.toString() ?? '',
    tokenType: json['token_type']?.toString() ?? 'bearer',
    cliente: ClienteModel.fromJson(json['cliente'] as Map<String, dynamic>),
  );
}
