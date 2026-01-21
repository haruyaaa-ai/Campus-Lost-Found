import 'dart:io';
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firebase_service.dart';
import '../services/api_service.dart';

class ItemProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final ApiService _apiService = ApiService();
  
  // Set to true to use REST API, false to use Firebase
  bool _useRestApi = false;
  
  List<Item> _items = [];
  bool _isLoading = false;

  ItemProvider() {
    _loadData();
  }

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  bool get isUsingRestApi => _useRestApi;

  void toggleDataSource() {
    _useRestApi = !_useRestApi;
    _loadData();
  }

  void _loadData() {
    if (_useRestApi) {
      fetchItemsFromApi();
    } else {
      _listenToFirebaseItems();
    }
  }

  Future<void> refreshData() async {
    _loadData();
    // For Firebase, it's a stream, so we just wait a bit to simulate refresh
    // For API, it's a real awaitable call
    if (_useRestApi) {
      await fetchItemsFromApi();
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  // --- Firebase Logic ---
  void _listenToFirebaseItems() {
    _isLoading = true;
    notifyListeners();
    // Note: This creates a listener that might need cancelling if we switch back and forth frequently
    // For a simple toggle, this is acceptable, but in production, managing stream subscriptions is better.
    _firebaseService.getItems().listen((updatedItems) {
      if (!_useRestApi) { // Only update if still in Firebase mode
        _items = updatedItems;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // --- REST API Logic ---
  Future<void> fetchItemsFromApi() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _apiService.getItems();
    } catch (e) {
      print('Error fetching items from API: $e');
      // Optionally handle error state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Item> getLostItems() =>
      _items.where((item) => item.type == ItemType.lost).toList();

  List<Item> getFoundItems() =>
      _items.where((item) => item.type == ItemType.found).toList();

  List<Item> getMyReports(String reporterEmail) =>
      _items.where((item) => item.reporterEmail == reporterEmail).toList();

  Future<void> addItem(Item item, [File? imageFile]) async {
    try {
      // Upload image if provided, regardless of the data source (REST API or Firebase)
      // We use Firebase Storage for simplicity as the Mock API doesn't support file upload
      if (imageFile != null) {
        final imageUrl = await _firebaseService.uploadImage(imageFile, 'items');
        item = item.copyWith(imageUrls: [imageUrl]);
      }

      if (_useRestApi) {
        final newItem = await _apiService.createItem(item);
        _items.add(newItem);
        notifyListeners();
      } else {
        await _firebaseService.addItem(item);
      }
    } catch (e) {
      print('Error adding item: $e');
      rethrow;
    }
  }

  Future<void> updateItem(String id, Item updatedItem) async {
    try {
      if (_useRestApi) {
        final newItem = await _apiService.updateItem(id, updatedItem);
        final index = _items.indexWhere((item) => item.id == id);
        if (index != -1) {
          _items[index] = newItem;
          notifyListeners();
        }
      } else {
        await _firebaseService.updateItem(id, updatedItem);
      }
    } catch (e) {
      print('Error updating item: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      if (_useRestApi) {
        await _apiService.deleteItem(id);
        _items.removeWhere((item) => item.id == id);
        notifyListeners();
      } else {
        await _firebaseService.deleteItem(id);
      }
    } catch (e) {
      print('Error deleting item: $e');
      rethrow;
    }
  }

  Item? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Item> searchItems(String query) {
    // Local filter for loaded items (regardless of source)
    // If server-side search is needed, we should add a separate async method and update UI
    return _items
        .where(
          (item) =>
              item.title.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase()) ||
              item.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<void> markAsClaimed(String id, String claimerName, String claimerEmail) async {
    if (_useRestApi) {
      try {
        final newItem = await _apiService.markAsClaimed(id, claimerName, claimerEmail);
        final index = _items.indexWhere((item) => item.id == id);
        if (index != -1) {
          _items[index] = newItem;
          notifyListeners();
        }
      } catch (e) {
        print('Error marking as claimed in API: $e');
        rethrow;
      }
    } else {
      final item = getItemById(id);
      if (item != null) {
        await updateItem(
          id,
          item.copyWith(
            status: ItemStatus.claimed,
            claimerName: claimerName,
            claimerEmail: claimerEmail,
            dateClaimed: DateTime.now(),
          ),
        );
      }
    }
  }

  Future<void> markAsResolved(String id) async {
    if (_useRestApi) {
      try {
        // Since ApiService doesn't have markAsResolved yet, we use updateItem or specific logic
        // But for mockAPI, we can just use the standard update mechanism
        final item = getItemById(id);
        if (item != null) {
          final newItem = await _apiService.updateItem(id, item.copyWith(status: ItemStatus.resolved));
          final index = _items.indexWhere((i) => i.id == id);
          if (index != -1) {
            _items[index] = newItem;
            notifyListeners();
          }
        }
      } catch (e) {
        print('Error marking as resolved in API: $e');
        rethrow;
      }
    } else {
      final item = getItemById(id);
      if (item != null) {
        await updateItem(
          id,
          item.copyWith(status: ItemStatus.resolved),
        );
      }
    }
  }
}
