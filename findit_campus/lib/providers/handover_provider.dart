import 'package:flutter/material.dart';
import '../models/handover_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class HandoverProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  HandoverModel? _currentHandover;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  HandoverModel? get currentHandover => _currentHandover;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<bool> generateQr(String matchId) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    final result = await _api.post(
      ApiConfig.generateHandover,
      body: {'matchId': matchId},
    );

    _isLoading = false;

    if (result['success']) {
      _currentHandover = HandoverModel.fromJson(result['data']['handover']);
      _successMessage = result['data']['message'];
      _error = null;
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyQr(String qrToken) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    final result = await _api.post(
      ApiConfig.verifyHandover,
      body: {'qrToken': qrToken},
    );

    _isLoading = false;

    if (result['success']) {
      _currentHandover = HandoverModel.fromJson(result['data']['handover']);
      _successMessage = result['data']['message'];
      _error = null;
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchHandoverStatus(String id) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.get(ApiConfig.handoverStatus(id));

    _isLoading = false;

    if (result['success']) {
      _currentHandover = HandoverModel.fromJson(result['data']['handover']);
    }

    notifyListeners();
  }

  void clearState() {
    _currentHandover = null;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
