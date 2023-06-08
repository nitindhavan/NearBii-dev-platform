import 'dart:convert';

class ReferalTransactionModel {
  String referalCode;
  int timestamp;
  String referdTo;
  bool isVendor;
  ReferalTransactionModel({
    required this.referalCode,
    required this.timestamp,
    required this.referdTo,
    required this.isVendor,
  });

  ReferalTransactionModel copyWith({
    String? referalCode,
    int? timestamp,
    String? referdTo,
    bool? isVendor,
  }) {
    return ReferalTransactionModel(
      referalCode: referalCode ?? this.referalCode,
      timestamp: timestamp ?? this.timestamp,
      referdTo: referdTo ?? this.referdTo,
      isVendor: isVendor ?? this.isVendor,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'referalCode': referalCode});
    result.addAll({'timestamp': timestamp});
    result.addAll({'referdTo': referdTo});
    result.addAll({'isVendor': isVendor});

    return result;
  }

  factory ReferalTransactionModel.fromMap(Map<String, dynamic> map) {
    return ReferalTransactionModel(
      referalCode: map['referalCode'] ?? '',
      timestamp: map['timestamp']?.toInt() ?? 0,
      referdTo: map['referdTo'] ?? '',
      isVendor: map['isVendor'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReferalTransactionModel.fromJson(String source) =>
      ReferalTransactionModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ReferalTransactionModel(referalCode: $referalCode, timestamp: $timestamp, referdTo: $referdTo, isVendor: $isVendor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReferalTransactionModel &&
        other.referalCode == referalCode &&
        other.timestamp == timestamp &&
        other.referdTo == referdTo &&
        other.isVendor == isVendor;
  }

  @override
  int get hashCode {
    return referalCode.hashCode ^
        timestamp.hashCode ^
        referdTo.hashCode ^
        isVendor.hashCode;
  }
}
