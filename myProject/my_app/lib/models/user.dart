class User {
  final int id;
  final String name;
  final String email;
  final int coins;
  final int? totalCoinsEarned; // Optional
  final DateTime? createdAt; // Optional

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.coins,
    this.totalCoinsEarned,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['username'] ?? json['name'], 
      email: json['email'],
      coins: json['coins'],
      totalCoinsEarned: json['total_coins_earned'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'email': email,
      'coins': coins,
      if (totalCoinsEarned != null) 'total_coins_earned': totalCoinsEarned,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
