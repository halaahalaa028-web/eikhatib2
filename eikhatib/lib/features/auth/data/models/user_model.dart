import 'package:eikhatib/core/api/end_point.dart';

class UserModel {
  final String id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final String? phoneNumber;
  final bool? isPhoneVerified;
  final String role;
  final bool isApproved;
  final bool is2faEnabled;

  UserModel({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.phoneNumber,
    this.isPhoneVerified = false,
    this.role = 'user',
    this.isApproved = false,
    this.is2faEnabled = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? firstName,
    String? lastName,
    String? profileImage,
    String? phoneNumber,
    bool? isPhoneVerified,
    String? role,
    bool? isApproved,
    bool? is2faEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      is2faEnabled: is2faEnabled ?? this.is2faEnabled,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
      phoneNumber: json['phone_number'],
      isPhoneVerified:
          json['is_phone_verified'] == 1 || json['is_phone_verified'] == true,
      role: json['role'] ?? 'user',
      isApproved: json['is_approved'] == 1 || json['is_approved'] == true,
      is2faEnabled: json['is_2fa_enabled'] == 1 || json['is_2fa_enabled'] == true,
    );
  }

  String? get fullProfileImageUrl {
    if (profileImage == null || profileImage!.isEmpty) return null;
    if (profileImage!.startsWith('http')) return profileImage;

    // Remove leading slash if exists to avoid double slashes
    final path = profileImage!.startsWith('/')
        ? profileImage!.substring(1)
        : profileImage;
    return '${EndPoint.imageBaseUrl}/$path';
  }
}
