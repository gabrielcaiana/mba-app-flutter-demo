class User {
  final int? id;
  final String name;
  final String username;
  final String? password;
  final List<String> roles;

  User({
    this.id,
    required this.name,
    required this.username,
    this.password,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'username': username,
        if (password != null && password!.isNotEmpty) 'password': password,
        'roles': roles,
      };

  User copyWith({
    int? id,
    String? name,
    String? username,
    String? password,
    List<String>? roles,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        username: username ?? this.username,
        password: password ?? this.password,
        roles: roles ?? this.roles,
      );
}
