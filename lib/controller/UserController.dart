import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobileoffice/model/AccessToken.dart';
import 'package:mobileoffice/model/User.dart';
import 'dart:async';

import 'package:mobileoffice/storage/Config.dart';
import 'package:mobileoffice/api/WebService.dart';

class UserController {

  String userEmail;
  User user;
  WebService webService = WebService();

  //SINGLETON
  static final UserController _singleton = new UserController._internal();

  factory UserController() {
    return _singleton;
  }

  static UserController get() {
    return _singleton;
  }

  UserController._internal();
//!SINGLETON

  Future<void> login(String email, String password) async {
    AccessToken accessToken = await webService.postAuth(email, password);

    userEmail = email;
    await Config.setString(ConfigKeys.ACCESS_TOKEN, accessToken.access_token);
    await Config.setString(ConfigKeys.USER_EMAIL, email);

    var token = await FirebaseMessaging().getToken();
    await webService.postFirebaseToken(token);
  }

  Future<String> getAccessToken() {
    return Config.getString(ConfigKeys.ACCESS_TOKEN);
  }

  Future<bool> isUserLogged() async {
    var accessToken = await Config.getString(ConfigKeys.ACCESS_TOKEN);
    userEmail = await Config.getString(ConfigKeys.USER_EMAIL);
    return accessToken != null && accessToken.length > 0;
  }

  Future<bool> setAccessToken(String accessToken) {
    return Config.setString(ConfigKeys.ACCESS_TOKEN, accessToken);
  }

  Future<User> updateUser() async {
    return user = await webService.getUser();
  }

  Future<bool> logout() async {
    var tokenCleared = await Config.setString(ConfigKeys.ACCESS_TOKEN, "");
    var userCleared = await Config.setString(ConfigKeys.USER_EMAIL, "");

    user = null;
    userEmail = null;

    return tokenCleared && userCleared;
  }
}