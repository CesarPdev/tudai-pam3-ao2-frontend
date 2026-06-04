import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _loaded = false;
  bool _isAuth = false;
  bool get isAuth => _isAuth;

  static const _demoUser = 'admin@mail.com';
  static const _demoPass = '123456';

  Future<void> init() async {
    if (_loaded) return;
    _prefs = await SharedPreferences.getInstance();
    _isAuth = _prefs?.getBool('auth_ok') ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final ok = email.trim() == _demoUser && password == _demoPass;
    _isAuth = ok;
    notifyListeners();

    if (ok) {
      await (_prefs ??= await SharedPreferences.getInstance()).setBool(
        'auth_ok',
        true,
      );
    }
    return ok;
  }

  Future<void> logout() async {
    _isAuth = false;
    notifyListeners();
    await (_prefs ??= await SharedPreferences.getInstance()).setBool(
      'auth_ok',
      false,
    );
  }
}
