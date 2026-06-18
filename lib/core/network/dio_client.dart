import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';

class DioClient {
  static Dio? _instance;

  static Future<Dio> getInstance() async {
    if (_instance != null) return _instance!;

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final auth = await AuthService.getInstance();
        final token = await auth.getValidToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token inválido o expirado, reautenticar
          final auth = await AuthService.getInstance();
          final token = await auth.getValidToken();
          if (token != null) {
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (_) {}
          }
        }
        handler.next(error);
      },
    ));

    _instance = dio;
    return dio;
  }
}
