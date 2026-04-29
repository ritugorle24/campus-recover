class ItemLocation {
  final String building;
  final String floor;
  final String room;
  final String description;

  ItemLocation({
    this.building = '',
    this.floor = '',
    this.room = '',
    this.description = '',
  });

  factory ItemLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ItemLocation();
    return ItemLocation(
      building: json['building'] ?? '',
      floor: json['floor'] ?? '',
      room: json['room'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'building': building,
      'floor': floor,
      'room': room,
      'description': description,
    };
  }

  String get displayString {
    final parts = <String>[];
    if (building.isNotEmpty) parts.add(building);
    if (floor.isNotEmpty) parts.add('Floor $floor');
    if (room.isNotEmpty) parts.add('Room $room');
    if (description.isNotEmpty && parts.isEmpty) parts.add(description);
    return parts.isEmpty ? 'Unknown location' : parts.join(', ');
  }
}

class ItemModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type; // 'lost' or 'found'
  final List<String> images;
  final ItemLocation location;
  final DateTime date;
  final String status; // 'active', 'matched', 'resolved'
  final Map<String, dynamic>? postedBy;
  final String? matchedWith;
  final List<String> tags;
  final String color;
  final String brand;
  final DateTime? createdAt;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    this.images = const [],
    required this.location,
    required this.date,
    this.status = 'active',
    this.postedBy,
    this.matchedWith,
    this.tags = const [],
    this.color = '',
    this.brand = '',
    this.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Other',
      type: json['type'] ?? 'lost',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      location: ItemLocation.fromJson(json['location']),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      status: json['status'] ?? 'active',
      postedBy: json['postedBy'] is Map ? json['postedBy'] : null,
      matchedWith: json['matchedWith']?.toString(),
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : [],
      color: json['color'] ?? '',
      brand: json['brand'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'images': images,
      'location': location.toJson(),
      'date': date.toIso8601String(),
      'tags': tags,
      'color': color,
      'brand': brand,
    };
  }

  bool get isLost => type == 'lost';
  bool get isFound => type == 'found';
  bool get isActive => status == 'active';
  bool get isResolved => status == 'resolved';

  String get posterName => postedBy?['name'] ?? 'Unknown';
  String get posterAvatar => postedBy?['avatar'] ?? '';
  String get posterId => postedBy?['_id'] ?? '';
}
