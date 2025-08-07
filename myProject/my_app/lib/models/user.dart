class User {
  final int id;
  final String name;
  final String email;
  final int coins;
  final int totalCoinsEarned;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.coins,
    required this.totalCoinsEarned,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      coins: json['coins'],
      totalCoinsEarned: json['total_coins_earned'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'coins': coins,
      'total_coins_earned': totalCoinsEarned,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
