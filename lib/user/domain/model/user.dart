class User {
  final String token;
  final String? name;
  final String? lastname;
  final String email;
  final String? role;
  final String? image;

  const User({
    required this.token,
    this.name,
    this.lastname,
    required this.email,
    this.role,
    this.image,
  });
}
