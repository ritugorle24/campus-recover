import 'dart:io';
import 'package:dio/dio.dart';
import 'storage_service.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  final StorageService _storage = StorageService();

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refreshToken = await _storage.getRefreshToken();
          if (refreshToken != null) {
            try {
              final response = await Dio().post(
                '${ApiConfig.baseUrl}/api/auth/refresh',
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200) {
                final newAccessToken = response.data['accessToken'];
                final newRefreshToken = response.data['refreshToken'];
                
                await _storage.saveAccessToken(newAccessToken);
                await _storage.saveRefreshToken(newRefreshToken);

                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryResponse = await _dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (refreshError) {
              await _storage.clearAll();
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters, bool withAuth = true}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {dynamic body, bool withAuth = true}) async {
    try {
      final response = await _dio.post(path, data: body);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, {dynamic body, bool withAuth = true}) async {
    try {
      final response = await _dio.put(path, data: body);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String path, {bool withAuth = true}) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> postMultipart(String path, {required Map<String, dynamic> fields, List<File>? files, String fileField = 'images'}) async {
    try {
      final formDataMap = Map<String, dynamic>.from(fields);
      if (files != null) {
        formDataMap[fileField] = files.map((f) => MultipartFile.fromFileSync(f.path)).toList();
      }
      final response = await _dio.post(path, data: FormData.fromMap(formDataMap));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> putMultipart(String path, {required Map<String, dynamic> fields, File? file, String fileField = 'avatar'}) async {
    try {
      final formDataMap = Map<String, dynamic>.from(fields);
      if (file != null) {
        formDataMap[fileField] = await MultipartFile.fromFile(file.path);
      }
      final response = await _dio.put(path, data: FormData.fromMap(formDataMap));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    final body = response.data;
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      return {'success': true, 'data': body, 'statusCode': response.statusCode};
    } else {
      return {
        'success': false,
        'message': body is Map ? (body['message'] ?? 'Error') : 'Error',
        'statusCode': response.statusCode,
        'data': body,
      };
    }
  }

  Map<String, dynamic> _handleError(dynamic error) {
    String message = 'Network error';
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout) message = 'Connection timeout';
      if (error.response?.data != null && error.response?.data is Map) {
        message = error.response?.data['message'] ?? message;
      }
    }
    return {'success': false, 'message': message, 'statusCode': 0};
  }
}
