class HandoverModel {
  final String id;
  final String matchId;
  final String qrToken;
  final String generatedBy;
  final String? scannedBy;
  final String status; // 'pending', 'completed', 'expired'
  final DateTime? completedAt;
  final DateTime expiresAt;
  final DateTime createdAt;

  HandoverModel({
    required this.id,
    required this.matchId,
    required this.qrToken,
    required this.generatedBy,
    this.scannedBy,
    this.status = 'pending',
    this.completedAt,
    required this.expiresAt,
    required this.createdAt,
  });

  factory HandoverModel.fromJson(Map<String, dynamic> json) {
    return HandoverModel(
      id: json['_id'] ?? json['id'] ?? '',
      matchId: json['match'] is String
          ? json['match']
          : (json['match']?['_id'] ?? ''),
      qrToken: json['qrToken'] ?? '',
      generatedBy: json['generatedBy'] is String
          ? json['generatedBy']
          : (json['generatedBy']?['_id'] ?? ''),
      scannedBy: json['scannedBy'] is String
          ? json['scannedBy']
          : json['scannedBy']?['_id'],
      status: json['status'] ?? 'pending',
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(minutes: 15)),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  bool get isExpired =>
      status == 'expired' || DateTime.now().isAfter(expiresAt);
  bool get isPending => status == 'pending' && !isExpired;
  bool get isCompleted => status == 'completed';

  Duration get timeRemaining {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}
