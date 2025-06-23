class User {
  final int? id; // Added ID (nullable in case it's not returned from backend)
  final String email;
  final String anonUsername;
  final String language;
  final String token;

  const User({
    this.id,
    required this.email,
    required this.anonUsername,
    required this.language,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // null-safe
      email: json['email'],
      anonUsername: json['anonUsername'],
      language: json['language'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'anonUsername': anonUsername,
      'language': language,
      'token': token,
    };
  }

  String get languagePreference => language;
}