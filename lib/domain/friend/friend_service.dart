import 'package:dio/dio.dart';
import 'package:movemore/domain/friend/friend.dart';
import 'package:movemore/domain/friend/friend_search/friend_search_result.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/domain/network/dio_provider.dart';

const kFriendAddTokenExpiredErrorName = "TECHNICAL_FRIEND_ADD_TOKEN_EXPIRED";

final friendService = FriendService();

class FriendService {
  Future<List<FriendSearchResult>> findFriends(String query) async {
    final Response<List<dynamic>> searchResults = await dio.get('/friend/search/$query');
    return searchResults.data!.map((searchResult) => FriendSearchResult.fromJson(searchResult)).toList();
  }

  Future<bool> sendFriendRequest(int friendId) async {
    final Response<dynamic> result = await dio.post('/friend', data: {"friendId": friendId});
    final sentResponse = SendOrAcceptFriendRequestResponse.fromJson(result.data);
    return sentResponse.hasSent ?? false;
  }

  Future<List<Friend>> listFriendRequests() async {
    final Response<List<dynamic>> friendRequestResult = await dio.get('/friend/requests');
    return friendRequestResult.data!.map((friend) => Friend.fromJson(friend)).toList();
  }

  Future<bool> acceptFriendRequest(int friendId) async {
    final Response<dynamic> result = await dio.post('/friend', data: {"friendId": friendId});
    final acceptResponse = SendOrAcceptFriendRequestResponse.fromJson(result.data);
    return acceptResponse.hasAccepted ?? false;
  }

  Future<bool> rejectFriendRequest(int friendId) async {
    final Response result = await dio.delete('/friend/request/$friendId');
    return result.statusCode == 200;
  }

  Future<List<Friend>> listFriends() async {
    final Response<List<dynamic>> friendListResult = await dio.get('/friends');
    return friendListResult.data!.map((friend) => Friend.fromJson(friend)).toList();
  }

  Future<String> removeFriend(int friendId) async {
    final Response result = await dio.delete<String>('/friend/$friendId');
    final readdToken = result.data;
    return readdToken;
  }

  Future<String> createFriendAddToken() async {
    final Response<dynamic> result = await dio.post('/friend/token', data: {});
    final tokenResponse = CreateFriendAddTokenResponse.fromJson(result.data);
    return tokenResponse.token;
  }

  Future<bool> redeemFriendAddToken(String token) async {
    try {
      final Response result = await dio.post('/friend/token/$token', data: {});
      return result.statusCode == 200;
    } on ApiException catch (e) {
      if (e.message == kFriendAddTokenExpiredErrorName) {
        return false;
      }
      rethrow;
    }
  }
}
