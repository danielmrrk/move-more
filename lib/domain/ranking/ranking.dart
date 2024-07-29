import 'package:movemore/general/model/user.dart';

class RankedUser extends User {
  int score;

  RankedUser({
    required super.userId,
    required super.username,
    required this.score,
  });

  factory RankedUser.fromJson(Map<String, dynamic> json) {
    return RankedUser(userId: json['userId'], username: json['username'], score: json['score']);
  }
}
