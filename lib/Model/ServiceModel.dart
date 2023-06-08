import 'dart:convert';

import 'package:flutter/foundation.dart';

class ServiceModel {
  final String id;
  final String image;
  final List<Subcategory> subcategory;
  final bool isActive;
  final int order;
  ServiceModel({
    required this.id,
    required this.image,
    required this.subcategory,
    required this.isActive,
    required this.order,
  });

  ServiceModel copyWith({
    String? id,
    String? image,
    List<Subcategory>? subcategory,
    bool? isActive,
    int? order,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      image: image ?? this.image,
      subcategory: subcategory ?? this.subcategory,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'image': image});
    result.addAll({'subcategory': subcategory.map((x) => x.toMap()).toList()});
    result.addAll({'isActive': isActive});
    result.addAll({'order': order});

    return result;
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      image: map['image'] ?? '',
      subcategory: List<Subcategory>.from(
          map['subcategory']?.map((x) => Subcategory.fromMap(x))),
      isActive: map['isActive'] ?? false,
      order: map['order']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceModel.fromJson(String source) =>
      ServiceModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ServiceModel(id: $id, image: $image, subcategory: $subcategory, isActive: $isActive, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServiceModel &&
        other.id == id &&
        other.image == image &&
        listEquals(other.subcategory, subcategory) &&
        other.isActive == isActive &&
        other.order == order;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        image.hashCode ^
        subcategory.hashCode ^
        isActive.hashCode ^
        order.hashCode;
  }
}

class Subcategory {
  final String id;
  final String image;
  final String bg;
  final String title;
  final int order;
  Subcategory({
    required this.id,
    required this.image,
    required this.bg,
    required this.title,
    required this.order,
  });

  Subcategory copyWith({
    String? id,
    String? image,
    String? bg,
    String? title,
    int? order,
  }) {
    return Subcategory(
      id: id ?? this.id,
      image: image ?? this.image,
      bg: bg ?? this.bg,
      title: title ?? this.title,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'image': image});
    result.addAll({'bg': bg});
    result.addAll({'title': title});
    result.addAll({'order': order});

    return result;
  }

  factory Subcategory.fromMap(Map<String, dynamic> map) {
    return Subcategory(
      id: map['id'] ?? '',
      image: map['image'] ?? '',
      bg: map['bg'] ?? '',
      title: map['title'] ?? '',
      order: map['order']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Subcategory.fromJson(String source) =>
      Subcategory.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Subcategory(id: $id, image: $image, bg: $bg, title: $title, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Subcategory &&
        other.id == id &&
        other.image == image &&
        other.bg == bg &&
        other.title == title &&
        other.order == order;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        image.hashCode ^
        bg.hashCode ^
        title.hashCode ^
        order.hashCode;
  }
}
