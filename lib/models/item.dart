import 'package:flutter/material.dart';

enum ItemType { lost, found }

enum ItemStatus { open, claimed, resolved }

class Item {
  final String id;
  final String title;
  final String description;
  final ItemType type;
  final ItemStatus status;
  final String category;
  final DateTime dateReported;
  final DateTime? dateLost;
  final String location;
  final String locationDetail;
  final String reporterName;
  final String reporterEmail;
  final String reporterPhone;
  final List<String> imageUrls;
  final String? claimerName;
  final String? claimerEmail;
  final DateTime? dateClaimed;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.category,
    required this.dateReported,
    this.dateLost,
    required this.location,
    this.locationDetail = '',
    required this.reporterName,
    required this.reporterEmail,
    required this.reporterPhone,
    required this.imageUrls,
    this.claimerName,
    this.claimerEmail,
    this.dateClaimed,
  });

  // Convert Map to Item
  factory Item.fromMap(Map<String, dynamic> map, String id) {
    return Item(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: ItemType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => ItemType.lost,
      ),
      status: ItemStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ItemStatus.open,
      ),
      category: map['category'] ?? '',
      dateReported: map['dateReported'] != null
          ? (map['dateReported'] as dynamic).toDate()
          : DateTime.now(),
      dateLost: map['dateLost'] != null
          ? (map['dateLost'] as dynamic).toDate()
          : null,
      location: map['location'] ?? '',
      locationDetail: map['locationDetail'] ?? '',
      reporterName: map['reporterName'] ?? '',
      reporterEmail: map['reporterEmail'] ?? '',
      reporterPhone: map['reporterPhone'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      claimerName: map['claimerName'],
      claimerEmail: map['claimerEmail'],
      dateClaimed: map['dateClaimed'] != null
          ? (map['dateClaimed'] as dynamic).toDate()
          : null,
    );
  }

  // Factory constructor for REST API JSON
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: _parseItemType(json['type']),
      status: _parseItemStatus(json['status']),
      category: json['category'] ?? '',
      dateReported: _parseDateTime(json['dateReported']) ?? DateTime.now(),
      dateLost: _parseDateTime(json['dateLost']),
      location: json['location'] ?? '',
      locationDetail: json['locationDetail'] ?? '',
      reporterName: json['reporterName'] ?? '',
      reporterEmail: json['reporterEmail'] ?? '',
      reporterPhone: json['reporterPhone'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      claimerName: json['claimerName'],
      claimerEmail: json['claimerEmail'],
      dateClaimed: _parseDateTime(json['dateClaimed']),
    );
  }

  // Helper method to parse ItemType from string
  static ItemType _parseItemType(dynamic value) {
    if (value == null) return ItemType.lost;
    final str = value.toString().toLowerCase();
    if (str.contains('found')) return ItemType.found;
    return ItemType.lost;
  }

  // Helper method to parse ItemStatus from string
  static ItemStatus _parseItemStatus(dynamic value) {
    if (value == null) return ItemStatus.open;
    final str = value.toString().toLowerCase();
    if (str.contains('claimed')) return ItemStatus.claimed;
    if (str.contains('resolved')) return ItemStatus.resolved;
    return ItemStatus.open;
  }

  // Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    // Handle Firestore Timestamp
    if (value.runtimeType.toString().contains('Timestamp')) {
      return (value as dynamic).toDate();
    }
    return null;
  }

  // Convert Item to JSON for REST API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'category': category,
      'dateReported': dateReported.toIso8601String(),
      'dateLost': dateLost?.toIso8601String(),
      'location': location,
      'locationDetail': locationDetail,
      'reporterName': reporterName,
      'reporterEmail': reporterEmail,
      'reporterPhone': reporterPhone,
      'imageUrls': imageUrls,
      'claimerName': claimerName,
      'claimerEmail': claimerEmail,
      'dateClaimed': dateClaimed?.toIso8601String(),
    };
  }

  // Convert Item to Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.toString(),
      'status': status.toString(),
      'category': category,
      'dateReported': dateReported,
      'dateLost': dateLost,
      'location': location,
      'locationDetail': locationDetail,
      'reporterName': reporterName,
      'reporterEmail': reporterEmail,
      'reporterPhone': reporterPhone,
      'imageUrls': imageUrls,
      'claimerName': claimerName,
      'claimerEmail': claimerEmail,
      'dateClaimed': dateClaimed,
    };
  }

  // Create a copy with modified fields
  Item copyWith({
    String? id,
    String? title,
    String? description,
    ItemType? type,
    ItemStatus? status,
    String? category,
    DateTime? dateReported,
    DateTime? dateLost,
    String? location,
    String? locationDetail,
    String? reporterName,
    String? reporterEmail,
    String? reporterPhone,
    List<String>? imageUrls,
    String? claimerName,
    String? claimerEmail,
    DateTime? dateClaimed,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      dateReported: dateReported ?? this.dateReported,
      dateLost: dateLost ?? this.dateLost,
      location: location ?? this.location,
      locationDetail: locationDetail ?? this.locationDetail,
      reporterName: reporterName ?? this.reporterName,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      imageUrls: imageUrls ?? this.imageUrls,
      claimerName: claimerName ?? this.claimerName,
      claimerEmail: claimerEmail ?? this.claimerEmail,
      dateClaimed: dateClaimed ?? this.dateClaimed,
    );
  }
}
