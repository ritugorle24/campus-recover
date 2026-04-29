class UserModel {
  final String id;
  final String fullName;
  final String rollNumber;
  final String prn;
  final String college;
  final String department;
  final String phone;
  final String avatar;
  final int points;
  final int itemsReturned;
  final int itemsFound;
  final int itemsLost;
  final List<String> badges;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.rollNumber,
    required this.prn,
    this.college = '',
    this.department = '',
    this.phone = '',
    this.avatar = '',
    this.points = 0,
    this.itemsReturned = 0,
    this.itemsFound = 0,
    this.itemsLost = 0,
    this.badges = const [],
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      prn: json['prn'] ?? '',
      college: json['college'] ?? '',
      department: json['department'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
      points: json['points'] ?? 0,
      itemsReturned: json['itemsReturned'] ?? 0,
      itemsFound: json['itemsFound'] ?? 0,
      itemsLost: json['itemsLost'] ?? 0,
      badges: json['badges'] != null
          ? List<String>.from(json['badges'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'rollNumber': rollNumber,
      'prn': prn,
      'college': college,
      'department': department,
      'phone': phone,
      'avatar': avatar,
      'points': points,
      'itemsReturned': itemsReturned,
      'itemsFound': itemsFound,
      'itemsLost': itemsLost,
      'badges': badges,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? rollNumber,
    String? prn,
    String? college,
    String? department,
    String? phone,
    String? avatar,
    int? points,
    int? itemsReturned,
    int? itemsFound,
    int? itemsLost,
    List<String>? badges,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      rollNumber: rollNumber ?? this.rollNumber,
      prn: prn ?? this.prn,
      college: college ?? this.college,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      points: points ?? this.points,
      itemsReturned: itemsReturned ?? this.itemsReturned,
      itemsFound: itemsFound ?? this.itemsFound,
      itemsLost: itemsLost ?? this.itemsLost,
      badges: badges ?? this.badges,
      createdAt: createdAt,
    );
  }
}
