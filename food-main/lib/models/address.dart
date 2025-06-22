import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String id;
  final String userId;
  final String street;
  final String apartmentSuiteEtc;
  final String city;
  final String zipCode;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.street,
    required this.apartmentSuiteEtc,
    required this.city,
    required this.zipCode,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt, required String apartmentSuiteEtptc,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'street': street,
      'apartmentSuiteEtc': apartmentSuiteEtc,
      'city': city,
      'zipCode': zipCode,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Address.fromMap(Map<String, dynamic> map, String id) {
    return Address(
      id: id,
      userId: map['userId'] ?? '',
      street: map['street'] ?? '',
      apartmentSuiteEtc: map['apartmentSuiteEtc'] ?? '',
      city: map['city'] ?? '',
      zipCode: map['zipCode'] ?? '',
      isDefault: map['isDefault'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(), apartmentSuiteEtptc: '',
    );
  }

  Address copyWith({
    String? id,
    String? userId,
    String? street,
    String? apartmentSuiteEtc,
    String? city,
    String? zipCode,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      street: street ?? this.street,
      apartmentSuiteEtc: apartmentSuiteEtc ?? this.apartmentSuiteEtc,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), apartmentSuiteEtptc: '',
    );
  }
} 