// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CategoriesModel {
  final String image;
  final String name;
  final String desc;
  CategoriesModel({
    required this.image,
    required this.name,
    required this.desc,
  });

  CategoriesModel copyWith({
    String? image,
    String? name,
    String? desc,
  }) {
    return CategoriesModel(
      image: image ?? this.image,
      name: name ?? this.name,
      desc: desc ?? this.desc,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'image': image,
      'name': name,
      'desc': desc,
    };
  }

  factory CategoriesModel.fromMap(Map<String, dynamic> map) {
    return CategoriesModel(
      image: map['image'] as String,
      name: map['name'] as String,
      desc: map['desc'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoriesModel.fromJson(String source) => CategoriesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CategoriesModel(image: $image, name: $name, desc: $desc)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CategoriesModel &&
      other.image == image &&
      other.name == name &&
      other.desc == desc;
  }

  @override
  int get hashCode => image.hashCode ^ name.hashCode ^ desc.hashCode;
}
