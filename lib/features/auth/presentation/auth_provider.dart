import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/cliente_model.dart';
import '../../dashboard/presentation/dashboard_provider.dart';
import '../../cuentas/presentation/cuentas_provider.dart';
import '../../creditos/presentation/creditos_provider.dart';
import '../../movimientos/presentation/movimientos_provider.dart';
import '../../notificaciones/presentation/notificaciones_provider.dart';
import '../../perfil/presentation/perfil_provider.dart';
import '../../pagos/presentation/pagos_provider.dart';
import '../../solicitar_credito/presentation/solicitar_credito_provider.dart';
import '../../estado_solicitudes/presentation/estado_solicitudes_provider.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final ClienteModel? cliente;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.uninitialized,
    this.cliente,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    ClienteModel? cliente,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      cliente: cliente ?? this.cliente,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState());

  /// Invalida todos los providers de datos para que se refresquen
  /// al cambiar de usuario (login/logout).
  void _invalidarDatos() {
    _ref.invalidate(dashboardResumenProvider);
    _ref.invalidate(cuentasListProvider);
    _ref.invalidate(creditosListProvider);
    _ref.invalidate(cronogramaProvider);
    _ref.invalidate(movimientosListProvider);
    _ref.invalidate(notificacionesListProvider);
    _ref.invalidate(perfilProvider);
    _ref.invalidate(cuentasOrigenProvider);
    _ref.invalidate(creditoInfoProvider);
    _ref.invalidate(solicitudesListProvider);
    _ref.invalidate(crearSolicitudProvider);
    _ref.invalidate(solicitudDetalleProvider);
    _ref.invalidate(estadoSolicitudesListProvider);
  }

  Future<void> checkSession() async {
    debugPrint('[AuthProvider] checkSession() iniciando');
    state = state.copyWith(status: AuthStatus.loading);
    final hasSession = await _repository.hasSession();
    debugPrint('[AuthProvider] checkSession() hasSession: $hasSession');
    if (hasSession) {
      try {
        final perfil = await _repository.getPerfil();
        debugPrint('[AuthProvider] checkSession() perfil obtenido: ${perfil.nombres} ${perfil.apellidos}');
        state = state.copyWith(
          status: AuthStatus.authenticated,
          cliente: perfil,
        );
        debugPrint('[AuthProvider] checkSession() sesión restaurada correctamente');
      } catch (e) {
        debugPrint('[AuthProvider] checkSession() error al obtener perfil: $e');
        await _repository.logout();
        state = state.copyWith(status: AuthStatus.unauthenticated);
        debugPrint('[AuthProvider] checkSession() sesión limpiada por error');
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      debugPrint('[AuthProvider] checkSession() sin sesión previa');
    }
  }

  Future<RegistroResponse?> register({
    required String numeroDocumento,
    required String nombres,
    required String apellidos,
    required DateTime fechaNacimiento,
    required String estadoCivil,
    required String email,
    required String telefono,
    required String direccion,
    required String password,
    required bool aceptoTerminos,
  }) async {
    debugPrint('[AuthProvider] register() llamado - documento: $numeroDocumento');
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await _repository.register(
        numeroDocumento: numeroDocumento,
        nombres: nombres,
        apellidos: apellidos,
        fechaNacimiento: fechaNacimiento,
        estadoCivil: estadoCivil,
        email: email,
        telefono: telefono,
        direccion: direccion,
        password: password,
        aceptoTerminos: aceptoTerminos,
      );
      debugPrint('[AuthProvider] register() exitoso - status: ${resp.status}');
      state = state.copyWith(isLoading: false);
      return resp;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').replaceFirst('DioException: ', '');
      debugPrint('[AuthProvider] register() error capturado - msg: "$msg"');
      String detail;
      if (msg.contains('400')) {
        detail = msg;
      } else if (msg.contains('422')) {
        detail = 'Datos inválidos. Verifica los campos.';
      } else if (msg.contains('connection timeout') || msg.contains('ConnectionTimeout') || msg.contains('connect timeout')) {
        detail = 'Error de conexión: el servidor no responde. Verifica que el backend esté activo.';
      } else if (msg.contains('Connection refused') || msg.contains('connection refused')) {
        detail = 'Error de conexión: no se pudo conectar al servidor. Verifica que el backend esté corriendo en localhost:8003.';
      } else {
        detail = 'Error de conexión. Intenta de nuevo.';
      }
      debugPrint('[AuthProvider] register() errorMessage final: "$detail"');
      state = state.copyWith(isLoading: false, errorMessage: detail);
      return null;
    }
  }

  Future<void> login(String documento, String password) async {
    debugPrint('[AuthProvider] login() llamado - documento: $documento');
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _repository.login(documento, password);
      debugPrint('[AuthProvider] login() exitoso - cliente: ${response.cliente.nombres} ${response.cliente.apellidos}');
      _invalidarDatos();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        cliente: response.cliente,
        isLoading: false,
      );
      debugPrint('[AuthProvider] login() estado cambiado a authenticated');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').replaceFirst('DioException: ', '');
      debugPrint('[AuthProvider] login() error capturado - msg original: "$msg"');
      String userMessage;
      if (msg.contains('401')) {
        userMessage = 'Credenciales incorrectas';
      } else if (msg.contains('connection timeout') || msg.contains('ConnectionTimeout') || msg.contains('connect timeout')) {
        userMessage = 'Error de conexión: el servidor no responde. Verifica que el backend esté activo.';
      } else if (msg.contains('Connection refused') || msg.contains('connection refused')) {
        userMessage = 'Error de conexión: no se pudo conectar al servidor. Verifica que el backend esté corriendo en localhost:8003.';
      } else {
        userMessage = 'Error de conexión. Intenta de nuevo.';
      }
      debugPrint('[AuthProvider] login() mensaje para usuario: "$userMessage"');
      state = state.copyWith(
        isLoading: false,
        errorMessage: userMessage,
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _invalidarDatos();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});
