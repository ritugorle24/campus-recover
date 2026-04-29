import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? relatedId;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'SYSTEM',
      relatedId: json['relatedId'],
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class NotificationProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.get('/api/notifications');
      if (result['success']) {
        final List data = result['data']['notifications'] ?? [];
        _notifications = data.map((n) => NotificationModel.fromJson(n)).toList();
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Failed to load notifications';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final result = await _api.put('/api/notifications/$id/read');
      if (result['success']) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            title: _notifications[index].title,
            body: _notifications[index].body,
            type: _notifications[index].type,
            relatedId: _notifications[index].relatedId,
            read: true,
            createdAt: _notifications[index].createdAt,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final result = await _api.put('/api/notifications/read-all');
      if (result['success']) {
        _notifications = _notifications.map((n) => NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          relatedId: n.relatedId,
          read: true,
          createdAt: n.createdAt,
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }
}
