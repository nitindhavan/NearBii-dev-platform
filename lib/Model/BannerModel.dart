import 'dart:convert';

class BannerModel {
  final String imageUrl;
  final String name;
  final bool isActive;
  BannerModel({
    required this.imageUrl,
    required this.name,
    required this.isActive,
  });

  BannerModel copyWith({
    String? imageUrl,
    String? name,
    bool? isActive,
  }) {
    return BannerModel(
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'imageUrl': imageUrl});
    result.addAll({'name': name});
    result.addAll({'isActive': isActive});
  
    return result;
  }

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      imageUrl: map['imageUrl'] ?? '',
      name: map['name'] ?? '',
      isActive: map['isActive'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory BannerModel.fromJson(String source) => BannerModel.fromMap(json.decode(source));

  @override
  String toString() => 'BannerModel(imageUrl: $imageUrl, name: $name, isActive: $isActive)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is BannerModel &&
      other.imageUrl == imageUrl &&
      other.name == name &&
      other.isActive == isActive;
  }

  @override
  int get hashCode => imageUrl.hashCode ^ name.hashCode ^ isActive.hashCode;
}