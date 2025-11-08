class SessionEntity {
  final int? id;
  final String token;
  final String? name;
  final String? lastname;
  final String? email;
  final String? role;
  final String? image;
  final int createdAt;

  const SessionEntity({
    this.id,
    required this.token,
    this.name,
    this.lastname,
    this.email,
    this.role,
    this.image,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'token': token,
        'name': name,
        'lastname': lastname,
        'email': email,
        'role': role,
        'image': image,
        'createdAt': createdAt,
      };

  factory SessionEntity.fromMap(Map<String, Object?> map) {
    return SessionEntity(
      id: map['id'] as int?,
      token: map['token'] as String,
      name: map['name'] as String?,
      lastname: map['lastname'] as String?,
      email: map['email'] as String?,
      role: map['role'] as String?,
      image: map['image'] as String?,
      createdAt: map['createdAt'] as int,
    );
  }
}
