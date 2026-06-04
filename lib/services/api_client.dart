import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clave usada para guardar/leer el JWT en SharedPreferences.
const _kTokenKey = 'auth_token';

/// URL base del backend.
/// • Emulador Android    → 10.0.2.2:5150
/// • Dispositivo físico  → IP de tu máquina en la red local
/// • Web / Desktop local → localhost:5150
const String kBaseUrl = 'http://localhost:5150';

class ApiClient {
  ApiClient._();

  static final Dio _dio = _buildDio();

  /// Instancia global de Dio lista para usar en cualquier parte de la app.
  static Dio get instance => _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Leer el JWT desde SharedPreferences en cada petición.
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_kTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Puedes manejar errores globales aquí (ej: 401 → logout).
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}
