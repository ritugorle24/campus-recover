import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();
  final SocketService _socketService = SocketService();
  final ApiService _api = ApiService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      _user = await _authService.getCurrentUser();
      if (_user != null) {
        _isAuthenticated = true;
        await _socketService.connect();
        // Refresh user data from server
        await refreshProfile();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String prn, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.login(
      prn: prn,
      password: password,
    );

    _isLoading = false;

    if (result['success']) {
      _user = result['user'];
      _isAuthenticated = true;
      _error = null;
      await _socketService.connect();
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String rollNumber,
    required String prn,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.register(
      fullName: fullName,
      rollNumber: rollNumber,
      prn: prn,
      password: password,
      confirmPassword: confirmPassword,
    );

    _isLoading = false;

    if (result['success']) {
      _user = result['user'];
      _isAuthenticated = true;
      _error = null;
      await _socketService.connect();
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    _socketService.disconnect();
    await _authService.logout();

    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final result = await _api.get(ApiConfig.profile);
    if (result['success']) {
      _user = UserModel.fromJson(result['data']['user']);
      await _storage.saveUser(_user!);
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? college,
    String? department,
    String? phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    final fields = <String, String>{};
    if (name != null) fields['name'] = name;
    if (college != null) fields['college'] = college;
    if (department != null) fields['department'] = department;
    if (phone != null) fields['phone'] = phone;

    final result = await _api.putMultipart(
      ApiConfig.profile,
      fields: fields,
    );

    _isLoading = false;

    if (result['success']) {
      _user = UserModel.fromJson(result['data']['user']);
      await _storage.saveUser(_user!);
      notifyListeners();
      return true;
    }

    _error = result['message'];
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
