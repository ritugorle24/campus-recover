import 'item_model.dart';

class MatchModel {
  final String id;
  final String? lostItemId;
  final String? foundItemId;
  final ItemModel? lostItem;
  final ItemModel? foundItem;
  final int score;
  final String status; // 'pending', 'confirmed', 'rejected'
  final String suggestedBy; // 'system', 'user'
  final DateTime? createdAt;

  MatchModel({
    required this.id,
    this.lostItemId,
    this.foundItemId,
    this.lostItem,
    this.foundItem,
    required this.score,
    this.status = 'pending',
    this.suggestedBy = 'system',
    this.createdAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['_id'] ?? json['id'] ?? '',
      lostItemId: json['lostItem'] is String ? json['lostItem'] : null,
      foundItemId: json['foundItem'] is String ? json['foundItem'] : null,
      lostItem: json['lostItem'] is Map<String, dynamic>
          ? ItemModel.fromJson(json['lostItem'])
          : null,
      foundItem: json['foundItem'] is Map<String, dynamic>
          ? ItemModel.fromJson(json['foundItem'])
          : null,
      score: json['score'] ?? 0,
      status: json['status'] ?? 'pending',
      suggestedBy: json['suggestedBy'] ?? 'system',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'lostItem': lostItemId ?? lostItem?.id,
      'foundItem': foundItemId ?? foundItem?.id,
      'score': score,
      'status': status,
      'suggestedBy': suggestedBy,
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
}
