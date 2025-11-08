class UserDto {
  final String? name;
  final String? lastname;
  final String email;
  final String? role;
  final String? image;

  const UserDto({
    this.name,
    this.lastname,
    required this.email,
    this.role,
    this.image,
  });

  Map<String, dynamic> toJsonForSignUp({required String password}) => {
        'name': name ?? '',
        'lastname': lastname ?? '',
        'email': email,
        'password': password,
        'role': role ?? '',
        'image': image ?? '',
      };

  factory UserDto.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return UserDto(
        name: json['name'] as String?,
        lastname: json['lastname'] as String?,
        email: (json['email'] ?? '') as String,
        role: json['role'] as String?,
        image: json['image'] as String?,
      );
    }
    return UserDto(email: json?.toString() ?? '');
  }
}
