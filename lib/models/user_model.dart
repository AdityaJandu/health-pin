class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? organizationName;
  final bool isNgoVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.organizationName,
    required this.isNgoVerified,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      avatarUrl: map['avatar_url'],
      organizationName: map['organization_name'],
      isNgoVerified: map['is_ngo_verified'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'organization_name': organizationName,
      'is_ngo_verified': isNgoVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
