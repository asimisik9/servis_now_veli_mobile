class AuthUser {
  const AuthUser({
    required this.id,
    required this.role,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.organizationId,
    this.organizationName,
  });

  final String id;
  final String role;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? organizationId;
  final String? organizationName;

  bool get isParent => role == 'veli';

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      organizationId: json['organization_id']?.toString(),
      organizationName: json['organization_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'organization_id': organizationId,
      'organization_name': organizationName,
    };
  }
}
