import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.firebaseUid,
    this.role = 'passenger',
    this.locale = 'en',
    this.avatar,
    this.isActive = true,
    this.fcmToken,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? firebaseUid;
  final String role;
  final String locale;
  final String? avatar;
  final bool isActive;
  final String? fcmToken;

  bool get isDriver => role == 'driver';
  bool get isPassenger => role == 'passenger';

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? firebaseUid,
    String? role,
    String? locale,
    String? avatar,
    bool? isActive,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      role: role ?? this.role,
      locale: locale ?? this.locale,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        firebaseUid,
        role,
        locale,
        avatar,
        isActive,
        fcmToken,
      ];
}
