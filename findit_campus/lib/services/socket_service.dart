import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';
import 'storage_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final StorageService _storage = StorageService();
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  Future<void> connect() async {
    if (_isConnected && _socket != null) return;

    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) {
      print('⚠️ Socket Connection Prevented: No valid token found.');
      return;
    }

    _socket = IO.io(ApiConfig.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
      'query': {'token': token},
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      print('🔌 Socket connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('🔌 Socket disconnected');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      print('❌ Socket connection error: $error');
    });

    _socket!.onError((error) {
      print('❌ Socket error: $error');
    });
  }

  void joinRoom(String matchId) {
    _socket?.emit('join_room', matchId);
  }

  void leaveRoom(String matchId) {
    _socket?.emit('leave_room', matchId);
  }

  void sendMessage({
    required String matchId,
    required String receiverId,
    required String message,
  }) {
    _socket?.emit('send_message', {
      'matchId': matchId,
      'receiverId': receiverId,
      'message': message,
    });
  }

  void sendTyping(String matchId) {
    _socket?.emit('typing', {'matchId': matchId});
  }

  void sendStopTyping(String matchId) {
    _socket?.emit('stop_typing', {'matchId': matchId});
  }

  void markAsRead(String matchId) {
    _socket?.emit('message_read', {'matchId': matchId});
  }

  void onReceiveMessage(Function(dynamic) callback) {
    _socket?.on('receive_message', callback);
  }

  void onNewMessageNotification(Function(dynamic) callback) {
    _socket?.on('new_message_notification', callback);
  }

  void onUserTyping(Function(dynamic) callback) {
    _socket?.on('user_typing', callback);
  }

  void onUserStopTyping(Function(dynamic) callback) {
    _socket?.on('user_stop_typing', callback);
  }

  void onMessagesRead(Function(dynamic) callback) {
    _socket?.on('messages_read', callback);
  }

  void offReceiveMessage() {
    _socket?.off('receive_message');
  }

  void offNewMessageNotification() {
    _socket?.off('new_message_notification');
  }

  void offUserTyping() {
    _socket?.off('user_typing');
  }

  void offUserStopTyping() {
    _socket?.off('user_stop_typing');
  }

  void offMessagesRead() {
    _socket?.off('messages_read');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }
}
