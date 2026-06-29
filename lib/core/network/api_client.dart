import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class ApiClient {
  // ── CAMBIAR SEGÚN RED ──────────────────────────────────────
  // Misma máquina (web/Android emulador)               → http://localhost:8003
  // USB tethering (Android) → ipconfig "Ethernet 2"    → http://10.17.155.155:8003
  // Cable Ethernet           → ipconfig "Ethernet"      → http://192.168.1.2:8003 ✓
  // Misma WiFi              → ipconfig "WiFi"           → http://192.168.x.x:8003
  static const String baseUrl = 'http://192.168.1.2:8003';

  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio dio;

  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    dio.interceptors.add(AuthInterceptor());
  }
}
