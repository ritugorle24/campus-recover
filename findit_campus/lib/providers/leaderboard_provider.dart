import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class LeaderboardEntry {
  final int rank;
  final String id;
  final String name;
  final String avatar;
  final String college;
  final int points;
  final int itemsReturned;
  final int itemsFound;
  final List<String> badges;

  LeaderboardEntry({
    required this.rank,
    required this.id,
    required this.name,
    this.avatar = '',
    this.college = '',
    required this.points,
    this.itemsReturned = 0,
    this.itemsFound = 0,
    this.badges = const [],
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      id: user['_id'] ?? '',
      name: user['name'] ?? '',
      avatar: user['avatar'] ?? '',
      college: user['college'] ?? '',
      points: user['points'] ?? 0,
      itemsReturned: user['itemsReturned'] ?? 0,
      itemsFound: user['itemsFound'] ?? 0,
      badges: user['badges'] != null
          ? List<String>.from(user['badges'])
          : [],
    );
  }
}

class LeaderboardProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<LeaderboardEntry> _leaderboard = [];
  int _myRank = 0;
  int _totalUsers = 0;
  bool _isLoading = false;
  String? _error;

  List<LeaderboardEntry> get leaderboard => _leaderboard;
  int get myRank => _myRank;
  int get totalUsers => _totalUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.get(ApiConfig.leaderboard);

    if (result['success']) {
      _leaderboard = (result['data']['leaderboard'] as List)
          .map((json) => LeaderboardEntry.fromJson(json))
          .toList();
      _error = null;
    } else {
      _error = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyRank() async {
    final result = await _api.get(ApiConfig.myRank);
    if (result['success']) {
      _myRank = result['data']['rank'] ?? 0;
      _totalUsers = result['data']['totalUsers'] ?? 0;
      notifyListeners();
    }
  }

  Future<void> fetchAll() async {
    await Future.wait([fetchLeaderboard(), fetchMyRank()]);
  }
}
