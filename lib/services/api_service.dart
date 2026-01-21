import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

/// REST API Service for Lost & Found items
/// Uses MockAPI.io or similar REST API backend
class ApiService {
  // Base URL for the REST API - you can replace this with your own API
  // Using a mock API endpoint for demonstration
  static const String baseUrl = 'https://6789a9fddd587da7ea2e51bc.mockapi.io/api/v1';
  
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // --- GET all items ---
  Future<List<Item>> getItems() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Item.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load items', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  // --- GET single item by ID ---
  Future<Item?> getItemById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/items/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Item.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ApiException('Failed to load item', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  // --- POST create new item ---
  Future<Item> createItem(Item item) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Item.fromJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to create item', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  // --- PUT update existing item ---
  Future<Item> updateItem(String id, Item item) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/items/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 200) {
        return Item.fromJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to update item', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  // --- DELETE item ---
  Future<bool> deleteItem(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/items/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw ApiException('Failed to delete item', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  // --- Search items ---
  Future<List<Item>> searchItems(String query) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/items?search=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Item.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to search items', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  // --- Filter items by type (lost/found) ---
  Future<List<Item>> getItemsByType(ItemType type) async {
    try {
      final typeString = type.toString().split('.').last;
      final response = await _client.get(
        Uri.parse('$baseUrl/items?type=$typeString'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Item.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to filter items', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  // --- Mark item as claimed ---
  Future<Item> markAsClaimed(String id, String claimerName, String claimerEmail) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl/items/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': 'claimed',
          'claimerName': claimerName,
          'claimerEmail': claimerEmail,
          'dateClaimed': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return Item.fromJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to mark item as claimed', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
