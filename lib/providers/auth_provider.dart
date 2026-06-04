import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';

/// Clave compartida con ApiClient para guardar/leer el JWT.
const _kTokenKey = 'auth_token';

class AuthProvider extends ChangeNotifier {
  bool _loaded = false;
  bool _isAuth = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuth => _isAuth;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final Dio _dio = ApiClient.instance;

  // ─────────────────────────────────────────────────────────────
  // Inicialización: verifica si existe un token guardado
  // ─────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    _isAuth = token != null && token.isNotEmpty;
    _loaded = true;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Login → POST /api/auth/login
  // ─────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email.trim(), 'password': password},
      );

      if (response.statusCode == 200) {
        final token = _extractToken(response.data);
        if (token == null) {
          _errorMessage = 'Respuesta inesperada del servidor.';
          _setLoading(false);
          return false;
        }
        await _saveToken(token);
        _isAuth = true;
        _setLoading(false);
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = _parseDioError(e);
    } catch (e) {
      _errorMessage = 'Error inesperado. Intente nuevamente.';
    }

    _setLoading(false);
    return false;
  }

  // ─────────────────────────────────────────────────────────────
  // Registro → POST /api/auth/register
  // ─────────────────────────────────────────────────────────────
  Future<bool> register(String email, String password, {String? nombre}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Modificamos el mapa para que coincida exactamente con el modelo Usuario de C#
      final body = <String, dynamic>{
        'userName': email.trim(), // Mapeamos el email al campo UserName esperado
        'password': password,
        'rol': 'user', // Opcional, pero recomendado si la BD exige un rol
      };
      
      // Nota: El campo 'nombre' del formulario no se envía aquí porque 
      // la tabla Usuarios no tiene esa columna, solo la tiene Contactos.

      final response = await _dio.post('/api/auth/register', data: body);

      // Muchas APIs devuelven 200 o 201 al registrar exitosamente.
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Intentar hacer login automático con las credenciales recibidas.
        _setLoading(false);
        return await login(email, password);
      }
    } on DioException catch (e) {
      _errorMessage = _parseDioError(e);
    } catch (e) {
      _errorMessage = 'Error inesperado. Intente nuevamente.';
    }

    _setLoading(false);
    return false;
  }

  // ─────────────────────────────────────────────────────────────
  // Logout: borra el token local
  // ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    _isAuth = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers privados
  // ─────────────────────────────────────────────────────────────

  /// Guarda el token en SharedPreferences.
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
  }

  /// Extrae el token del body de la respuesta.
  /// Ajusta los campos según la respuesta real de tu API
  /// (ej: 'token', 'accessToken', 'jwt', etc.).
  String? _extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['token'] as String? ??
          data['accessToken'] as String? ??
          data['jwt'] as String?;
    }
    return null;
  }

  /// Convierte errores de Dio en mensajes legibles para el usuario.
  String _parseDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'El servidor no responde. Verifique su conexión.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar al servidor.';
    }
    final statusCode = e.response?.statusCode;
    final serverMessage = e.response?.data is Map
        ? (e.response!.data['message'] ??
            e.response!.data['error'] ??
            e.response!.data['title'])
        : null;

    if (statusCode == 401 || statusCode == 403) {
      return serverMessage?.toString() ?? 'Usuario o contraseña incorrectos.';
    }
    if (statusCode == 400) {
      return serverMessage?.toString() ?? 'Datos inválidos. Revise el formulario.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Error interno del servidor. Intente más tarde.';
    }
    return serverMessage?.toString() ?? 'Error desconocido.';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
