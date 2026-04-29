class ChatMessageModel {
  final String id;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;
  final String matchId;
  final String message;
  final bool read;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    this.sender,
    this.receiver,
    required this.matchId,
    required this.message,
    this.read = false,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      sender: json['sender'] is Map ? json['sender'] : null,
      receiver: json['receiver'] is Map ? json['receiver'] : null,
      matchId: json['matchId'] ?? '',
      message: json['message'] ?? '',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  String get senderId => sender?['_id'] ?? '';
  String get senderName => sender?['fullName'] ?? sender?['name'] ?? 'Unknown';
  String get senderAvatar => sender?['avatar'] ?? '';
  String get receiverId => receiver?['_id'] ?? '';
}

class ConversationModel {
  final String matchId;
  final Map<String, dynamic>? match;
  final Map<String, dynamic>? otherUser;
  final ChatMessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  ConversationModel({
    required this.matchId,
    this.match,
    this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      matchId: json['matchId'] ?? '',
      match: json['match'],
      otherUser: json['otherUser'],
      lastMessage: json['lastMessage'] != null
          ? ChatMessageModel.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  String get otherUserName => otherUser?['fullName'] ?? otherUser?['name'] ?? 'Unknown';
  String get otherUserAvatar => otherUser?['avatar'] ?? '';
  String get otherUserId => otherUser?['_id'] ?? '';
}
