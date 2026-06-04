import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../services/api_client.dart';

class ContactsProvider extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  final List<Contact> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Contact> get items => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ─────────────────────────────────────────────────────────────
  // GET /minimal/contactos
  // ─────────────────────────────────────────────────────────────
  Future<void> fetchContacts() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _dio.get('/minimal/contactos');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        _contacts
          ..clear()
          ..addAll(data.map((e) => Contact.fromJson(e as Map<String, dynamic>)));
        _contacts.sort((a, b) =>
            a.apellido.toLowerCase().compareTo(b.apellido.toLowerCase()));
      }
    } on DioException catch (e) {
      _errorMessage = _parseDioError(e);
      debugPrint('[ContactsProvider] fetchContacts error: $_errorMessage');
    } catch (e) {
      _errorMessage = 'Error inesperado al cargar contactos.';
      debugPrint('[ContactsProvider] fetchContacts unexpected: $e');
    }

    _setLoading(false);
  }

  // ─────────────────────────────────────────────────────────────
  // POST /api/contacto/add
  // ─────────────────────────────────────────────────────────────
  Future<bool> addContact(Contact contact) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _dio.post(
        '/api/contacto/add',
        data: contact.toJsonCreate(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Recargamos la lista para obtener el ID asignado por el backend.
        await fetchContacts();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = _parseDioError(e);
      debugPrint('[ContactsProvider] addContact error: $_errorMessage');
    } catch (e) {
      _errorMessage = 'Error inesperado al agregar contacto.';
      debugPrint('[ContactsProvider] addContact unexpected: $e');
    }

    _setLoading(false);
    return false;
  }

  // ─────────────────────────────────────────────────────────────
  // PUT /api/contacto/edit/{id}
  // ─────────────────────────────────────────────────────────────
  Future<bool> updateContact(Contact contact) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _dio.put(
        '/api/contacto/edit/${contact.id}',
        data: contact.toJsonUpdate(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Actualización optimista en lista local.
        final index = _contacts.indexWhere((c) => c.id == contact.id);
        if (index != -1) {
          _contacts[index] = contact;
          _contacts.sort((a, b) =>
              a.apellido.toLowerCase().compareTo(b.apellido.toLowerCase()));
        } else {
          await fetchContacts();
        }
        _setLoading(false);
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = _parseDioError(e);
      debugPrint('[ContactsProvider] updateContact error: $_errorMessage');
    } catch (e) {
      _errorMessage = 'Error inesperado al actualizar contacto.';
      debugPrint('[ContactsProvider] updateContact unexpected: $e');
    }

    _setLoading(false);
    return false;
  }

  // ─────────────────────────────────────────────────────────────
  // DELETE /api/contacto/delete/{id}
  // ─────────────────────────────────────────────────────────────
  Future<bool> deleteContact(int id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _dio.delete('/api/contacto/delete/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _contacts.removeWhere((c) => c.id == id);
        _setLoading(false);
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = _parseDioError(e);
      debugPrint('[ContactsProvider] deleteContact error: $_errorMessage');
    } catch (e) {
      _errorMessage = 'Error inesperado al eliminar contacto.';
      debugPrint('[ContactsProvider] deleteContact unexpected: $e');
    }

    _setLoading(false);
    return false;
  }

  // ─────────────────────────────────────────────────────────────
  // Búsqueda local
  // ─────────────────────────────────────────────────────────────
  List<Contact> searchBy(String query) {
    final q = _normalize(query);
    return _contacts.where((c) {
      return _normalize(c.nombre).contains(q) ||
          _normalize(c.apellido).contains(q) ||
          _normalize(c.telefono).contains(q) ||
          _normalize(c.email).contains(q);
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers privados
  // ─────────────────────────────────────────────────────────────
  String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

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
      return 'No autorizado. Inicie sesión nuevamente.';
    }
    if (statusCode == 404) {
      return 'Contacto no encontrado.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Error interno del servidor.';
    }
    return serverMessage?.toString() ?? 'Error desconocido (código $statusCode).';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
