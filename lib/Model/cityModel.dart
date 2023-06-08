import 'dart:convert';

class Cities {
  final int id;
  final String name;
  Cities({
    required this.id,
    required this.name,
  });

  Cities copyWith({
    int? id,
    String? name,
  }) {
    return Cities(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory Cities.fromMap(Map<String, dynamic> map) {
    return Cities(
      id: map['id'].toInt() as int,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Cities.fromJson(String source) => Cities.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Cities(id: $id, name: $name)';

  @override
  bool operator ==(covariant Cities other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}