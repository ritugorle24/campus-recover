class ApiConfig {
  // For Android Emulator ALWAYS use 10.0.2.2 — this is how emulator reaches localhost
  static const String baseUrl = "https://findit-backend-1.onrender.com";
  static const String apiUrl = "$baseUrl/api";
  static const String socketUrl = baseUrl;

  // Auth endpoints
  static const String register = '$apiUrl/auth/register';
  static const String login = '$apiUrl/auth/login';
  static const String refresh = '$apiUrl/auth/refresh';
  static const String logout = '$apiUrl/auth/logout';

  // Item endpoints
  static const String items = '$apiUrl/items';
  static const String myItems = '$apiUrl/items/my';
  static const String searchItems = '$apiUrl/items/search';
  static String itemDetail(String id) => '$apiUrl/items/$id';
  static String itemMatches(String id) => '$apiUrl/items/$id/matches';

  // Chat endpoints
  static const String conversations = '$apiUrl/chat/conversations';
  static String messages(String matchId) => '$apiUrl/chat/messages/$matchId';

  // Handover endpoints
  static const String generateHandover = '$apiUrl/handover/generate';
  static const String verifyHandover = '$apiUrl/handover/verify';
  static String handoverStatus(String id) => '$apiUrl/handover/$id';

  // Leaderboard endpoints
  static const String leaderboard = '$apiUrl/leaderboard';
  static const String myRank = '$apiUrl/leaderboard/me';

  // User endpoints
  static const String profile = '$apiUrl/users/profile';
  static String userProfile(String id) => '$apiUrl/users/$id';

  // Image URL helper
  static String imageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }
}
