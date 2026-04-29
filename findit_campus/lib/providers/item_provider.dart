import 'dart:io';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import 'dart:convert';

class ItemProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<ItemModel> _items = [];
  List<ItemModel> _myItems = [];
  List<ItemModel> _searchResults = [];
  ItemModel? _currentItem;
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;

  List<ItemModel> get items => _items;
  List<ItemModel> get myItems => _myItems;
  List<ItemModel> get searchResults => _searchResults;
  ItemModel? get currentItem => _currentItem;
  List<Map<String, dynamic>> get matches => _matches;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  List<ItemModel> get lostItems => _items.where((i) => i.isLost).toList();
  List<ItemModel> get foundItems => _items.where((i) => i.isFound).toList();

  Future<void> fetchItems({String? type, String? category, bool refresh = false}) async {
    if (refresh) _currentPage = 1;
    _isLoading = true;
    _error = null;
    notifyListeners();

    String url = '${ApiConfig.items}?page=$_currentPage&limit=20';
    if (type != null) url += '&type=$type';
    if (category != null) url += '&category=$category';

    final result = await _api.get(url);

    _isLoading = false;

    if (result['success']) {
      final data = result['data'];
      final itemList = (data['items'] as List)
          .map((json) => ItemModel.fromJson(json))
          .toList();

      if (refresh || _currentPage == 1) {
        _items = itemList;
      } else {
        _items.addAll(itemList);
      }

      _totalPages = data['pagination']?['pages'] ?? 1;
      _error = null;
    } else {
      _error = result['message'];
    }

    notifyListeners();
  }

  Future<void> loadMore({String? type, String? category}) async {
    if (_currentPage < _totalPages) {
      _currentPage++;
      await fetchItems(type: type, category: category);
    }
  }

  Future<void> fetchMyItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.get(ApiConfig.myItems);

    _isLoading = false;

    if (result['success']) {
      _myItems = (result['data']['items'] as List)
          .map((json) => ItemModel.fromJson(json))
          .toList();
      _error = null;
    } else {
      _error = result['message'];
    }

    notifyListeners();
  }

  Future<void> fetchItemDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.get(ApiConfig.itemDetail(id));

    _isLoading = false;

    if (result['success']) {
      _currentItem = ItemModel.fromJson(result['data']['item']);
      _error = null;
    } else {
      _error = result['message'];
    }

    notifyListeners();
  }

  Future<void> fetchMatches(String itemId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.get(ApiConfig.itemMatches(itemId));

    _isLoading = false;

    if (result['success']) {
      _matches = List<Map<String, dynamic>>.from(result['data']['matches'] ?? []);
    } else {
      _matches = [];
    }

    notifyListeners();
  }

  Future<bool> reportItem({
    required String title,
    required String description,
    required String category,
    required String type,
    required DateTime date,
    required ItemLocation location,
    List<String> tags = const [],
    String color = '',
    String brand = '',
    String? securityQuestion,
    String? securityAnswer,
    List<File> images = const [],
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final fields = <String, String>{
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
      'location': jsonEncode(location.toJson()),
      'tags': jsonEncode(tags),
      'color': color,
      'brand': brand,
    };

    if (securityQuestion != null) fields['securityQuestion'] = securityQuestion;
    if (securityAnswer != null) fields['securityAnswer'] = securityAnswer;

    final result = await _api.postMultipart(
      ApiConfig.items,
      fields: fields,
      files: images.isNotEmpty ? images : null,
    );

    _isLoading = false;

    if (result['success']) {
      _error = null;
      // Refresh items list
      await fetchItems(refresh: true);
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> searchItems(String query, {String? type, String? category}) async {
    _isSearching = true;
    _error = null;
    notifyListeners();

    String url = '${ApiConfig.searchItems}?q=$query';
    if (type != null) url += '&type=$type';
    if (category != null) url += '&category=$category';

    final result = await _api.get(url);

    _isSearching = false;

    if (result['success']) {
      _searchResults = (result['data']['items'] as List)
          .map((json) => ItemModel.fromJson(json))
          .toList();
      _error = null;
    } else {
      _error = result['message'];
      _searchResults = [];
    }

    notifyListeners();
  }

  Future<bool> updateItem(String id, Map<String, dynamic> updates) async {
    final result = await _api.put(ApiConfig.itemDetail(id), body: updates);
    if (result['success']) {
      await fetchMyItems();
      return true;
    }
    return false;
  }

  Future<bool> deleteItem(String id) async {
    final result = await _api.delete(ApiConfig.itemDetail(id));
    if (result['success']) {
      _myItems.removeWhere((item) => item.id == id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<String?> fetchSecurityQuestion(String itemId) async {
    final result = await _api.get('${ApiConfig.items}/$itemId/security-question');
    if (result['success']) {
      return result['data']['question'];
    }
    return null;
  }

  Future<Map<String, dynamic>> submitClaim({
    required String itemId,
    String? matchId,
    required String answer,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.post(ApiConfig.claims, body: {
      'itemId': itemId,
      'matchId': matchId,
      'securityAnswer': answer,
      'uniqueDescription': description,
    });

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<Map<String, dynamic>> verifyClaim({
    required String matchId,
    required String action,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.put(
      ApiConfig.verifyClaim(matchId),
      body: {'action': action},
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
