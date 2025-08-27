class GoogleUser {
  final String userId;
  final String userName;
  final String avatarUrl;

  GoogleUser({
    required this.userId,
    required this.userName,
    required this.avatarUrl,
  });

  @override
  String toString() {
    return 'GoogleUser{userId: $userId, userName: $userName, avatarUrl: $avatarUrl}';
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
    };
  }

  factory GoogleUser.fromJson(Map<String, dynamic> json) {
    return GoogleUser(
      userId: json['userId'],
      userName: json['userName'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
