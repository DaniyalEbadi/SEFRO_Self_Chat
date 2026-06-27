class UserEntity {
  final String id;
  final String? email;
  final String? phone;
  final String? name;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isPremium;
  final Map<String, dynamic> preferences;

  UserEntity({
    required this.id,
    this.email,
    this.phone,
    this.name,
    this.avatarUrl,
    this.createdAt,
    this.lastLoginAt,
    this.isPremium = false,
    this.preferences = const {},
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isPremium,
    Map<String, dynamic>? preferences,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPremium: isPremium ?? this.isPremium,
      preferences: preferences ?? this.preferences,
    );
  }
}
