class FriendSearchResult {
  int userId;
  bool areFriends;
  String username;

  FriendSearchResult({required this.userId, required this.areFriends, required this.username});

  factory FriendSearchResult.fromJson(Map<String, dynamic> json) {
    return FriendSearchResult(
      userId: json['userId'] as int,
      areFriends: json['areFriends'] as bool,
      username: json['username'] as String,
    );
  }
}
