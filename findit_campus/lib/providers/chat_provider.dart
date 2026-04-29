import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../config/api_config.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final SocketService _socketService = SocketService();

  List<ConversationModel> _conversations = [];
  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _isOtherUserTyping = false;
  String? _currentMatchId;

  ChatProvider() {
    _socketService.onNewMessageNotification((data) {
      fetchConversations();
    });
  }

  List<ConversationModel> get conversations => _conversations;
  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOtherUserTyping => _isOtherUserTyping;

  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.get(ApiConfig.conversations);

    _isLoading = false;

    if (result['success']) {
      _conversations = (result['data']['conversations'] as List)
          .map((json) => ConversationModel.fromJson(json))
          .toList();
      _error = null;
    } else {
      _error = result['message'];
    }

    notifyListeners();
  }

  Future<void> fetchMessages(String matchId) async {
    _isLoading = true;
    _error = null;
    _currentMatchId = matchId;
    notifyListeners();

    final result = await _api.get(ApiConfig.messages(matchId));

    _isLoading = false;

    if (result['success']) {
      _messages = (result['data']['messages'] as List)
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();
      _error = null;
    } else {
      _error = result['message'];
    }

    notifyListeners();
  }

  void joinChatRoom(String matchId) {
    _currentMatchId = matchId;
    _socketService.joinRoom(matchId);

    // Listen for new messages
    _socketService.onReceiveMessage((data) {
      final message = ChatMessageModel.fromJson(data as Map<String, dynamic>);
      // Avoid duplicates
      if (!_messages.any((m) => m.id == message.id)) {
        _messages.add(message);
        notifyListeners();
      }
    });

    // Listen for typing indicators
    _socketService.onUserTyping((data) {
      _isOtherUserTyping = true;
      notifyListeners();
    });

    _socketService.onUserStopTyping((data) {
      _isOtherUserTyping = false;
      notifyListeners();
    });

    // Listen for read receipts
    _socketService.onMessagesRead((data) {
      notifyListeners();
    });
  }

  void leaveChatRoom(String matchId) {
    _socketService.leaveRoom(matchId);
    _socketService.offReceiveMessage();
    _socketService.offUserTyping();
    _socketService.offUserStopTyping();
    _socketService.offMessagesRead();
    _currentMatchId = null;
    _isOtherUserTyping = false;
  }

  void sendMessage({
    required String matchId,
    required String receiverId,
    required String message,
  }) {
    _socketService.sendMessage(
      matchId: matchId,
      receiverId: receiverId,
      message: message,
    );
  }

  void sendTyping(String matchId) {
    _socketService.sendTyping(matchId);
  }

  void sendStopTyping(String matchId) {
    _socketService.sendStopTyping(matchId);
  }

  void markAsRead(String matchId) {
    _socketService.markAsRead(matchId);
  }

  Future<String?> initializeChat(String itemId) async {
    final result = await _api.post(ApiConfig.initializeChat, body: {
      'itemId': itemId,
    });
    
    if (result['success']) {
      return result['data']['matchId'];
    }
    return null;
  }

  int get totalUnread {
    return _conversations.fold(0, (sum, c) => sum + c.unreadCount);
  }
}
