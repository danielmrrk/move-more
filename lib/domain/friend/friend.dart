class Friend {
  int userId;
  String username;

  Friend(this.userId, this.username);

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(json['userId'], json['username']);
  }
}

class SendOrAcceptFriendRequestResponse {
  bool? hasSent;
  bool? hasAccepted;

  SendOrAcceptFriendRequestResponse({this.hasSent, this.hasAccepted});

  factory SendOrAcceptFriendRequestResponse.fromJson(Map<String, dynamic> json) {
    return SendOrAcceptFriendRequestResponse(hasSent: json['hasSent'] == true, hasAccepted: json['hasAccepted'] == true);
  }
}

class CreateFriendAddTokenResponse {
  String token;

  CreateFriendAddTokenResponse({required this.token});

  factory CreateFriendAddTokenResponse.fromJson(Map<String, dynamic> json) {
    return CreateFriendAddTokenResponse(token: json['token']);
  }
}
