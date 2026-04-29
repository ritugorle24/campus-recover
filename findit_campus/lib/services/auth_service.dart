import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String rollNumber,
    required String prn,
    required String password,
    required String confirmPassword,
  }) async {
    final result = await _api.post(
      ApiConfig.register,
      body: {
        'fullName': fullName,
        'rollNumber': rollNumber,
        'prn': prn,
        'password': password,
        'confirmPassword': confirmPassword,
      },
      withAuth: false,
    );

    if (result['success']) {
      final data = result['data'];
      await _storage.saveAccessToken(data['accessToken']);
      await _storage.saveRefreshToken(data['refreshToken']);
      final user = UserModel.fromJson(data['user']);
      await _storage.saveUser(user);
      return {'success': true, 'user': user};
    }

    return {'success': false, 'message': result['message']};
  }

  Future<Map<String, dynamic>> login({
    required String prn,
    required String password,
  }) async {
    final result = await _api.post(
      ApiConfig.login,
      body: {
        'prn': prn,
        'password': password,
      },
      withAuth: false,
    );

    if (result['success']) {
      final data = result['data'];
      await _storage.saveAccessToken(data['accessToken']);
      await _storage.saveRefreshToken(data['refreshToken']);
      final user = UserModel.fromJson(data['user']);
      await _storage.saveUser(user);
      return {'success': true, 'user': user};
    }

    return {'success': false, 'message': result['message']};
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    final result = await _api.post(
      ApiConfig.refresh,
      body: {'refreshToken': refreshToken},
      withAuth: false,
    );

    if (result['success']) {
      final data = result['data'];
      await _storage.saveAccessToken(data['accessToken']);
      await _storage.saveRefreshToken(data['refreshToken']);
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.logout);
    } catch (_) {}
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    return token != null;
  }

  Future<UserModel?> getCurrentUser() async {
    return await _storage.getUser();
  }
}
