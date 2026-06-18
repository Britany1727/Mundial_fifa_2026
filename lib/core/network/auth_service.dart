import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthService {
  static AuthService? _instance;
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  String? _token;
  bool _authenticating = false;

  static Future<AuthService> getInstance() async {
    if (_instance == null) {
      _instance = AuthService._();
      await _instance!._loadToken();
    }
    return _instance!;
  }

  AuthService._();

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<String?> getValidToken() async {
    if (_token != null) return _token;
    if (_authenticating) return null;

    _authenticating = true;
    try {
      // Intentar login primero
      try {
        final res = await _dio.post('/auth/authenticate', data: {
          'email': 'app@mundial2026.app',
          'password': 'Mundial2026!',
        });
        final token = res.data['token'] as String?;
        if (token != null) {
          await _saveToken(token);
          return token;
        }
      } catch (_) {
        // login falló, registrar
      }

      final res = await _dio.post('/auth/register', data: {
        'name': 'Mundial App',
        'email': 'app@mundial2026.app',
        'password': 'Mundial2026!',
      });
      final token = res.data['token'] as String?;
      if (token != null) {
        await _saveToken(token);
        return token;
      }
    } catch (_) {
      // auth no disponible
    } finally {
      _authenticating = false;
    }
    return null;
  }
}
