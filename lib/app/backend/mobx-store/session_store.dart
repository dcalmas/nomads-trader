import 'dart:convert';

import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/backend/models/user_info_model.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:flutter_app/app/util/constant.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:mobx/mobx.dart';

import '../../env.dart';

part 'session_store.g.dart';

class SessionStore = _SessionStore with _$SessionStore;

abstract class _SessionStore with Store {
  SharedPreferencesManager? sharedPreferencesManager;
  ApiService? apiService;

  @observable
  String token = "";
  @observable
  UserInfoModel? userInfo;

  void initStore(sharedPref, apiServiceTemp) {
    sharedPreferencesManager = sharedPref;
    apiService = apiServiceTemp;
    getUser();
  }

  @action
  void setToken(value) {
    token = value;
  }

  @action
  void setUserInfo(value) {
    userInfo = value;
  }

  Future<void> getUser() async {
    final apiService = ApiService(appBaseUrl: Environments.apiBaseURL);
    
    if (sharedPreferencesManager == null) {
      return;
    }
    
    String tokenTemp = getToken();
    setToken(tokenTemp);
    if (token == "") return;
    
    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      String userId = payload["data"]["user"]["id"].toString();
      Response response = await apiService.getPrivate(
          AppConstants.getUser + "/" + userId, token, null);
      
      if (response.statusCode == 200) {
        UserInfoModel user = UserInfoModel.fromJson(response.body);
        saveUserInfo(user);
        setUserInfo(user);
      } else if (response.statusCode == 401 || response.statusCode == 404 || response.statusCode == 403) {
        // ЕГЕР ТОКЕН ЖАРАМСЫЗ БОЛСА НЕМЕСЕ АККАУНТ ӨШІРІЛГЕН БОЛСА
        print("SessionStore: Token invalid or User not found. Force Logout.");
        logout();
      }
    } catch (e) {
      print("SessionStore getUser Error: $e");
      // Қате болса (токен форматсыз болса т.б.) тазалап тастаймыз
      if (e.toString().contains('Invalid')) {
        logout();
      }
    }
  }

  void saveUserInfo(UserInfoModel user) {
    sharedPreferencesManager?.putString('user_info', jsonEncode(user.toJson()));
  }

  String getToken() {
    if (sharedPreferencesManager == null) {
      return "";
    }
    return sharedPreferencesManager!.getString('token') ?? "";
  }
  
  String getCurrentCoursesId(){
    if (sharedPreferencesManager == null) {
      return "";
    }
    return sharedPreferencesManager!.getString('overview') ?? "";
  }
  
   String getFcmToken(){
    if (sharedPreferencesManager == null) {
      return "";
    }
    return sharedPreferencesManager!.getString('fcm_token') ?? "";
  }
  
  @action
  Future<void> logout() async {
    // 1. Clear in-memory state
    token = "";
    userInfo = null;
    
    // 2. Clear from storage
    if (sharedPreferencesManager != null) {
      await sharedPreferencesManager!.clearAll();
      print('SessionStore: Storage cleared');
    }

    // 3. Reset controllers state
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.onInit(); 
      }
    } catch (e) {
      print("Error resetting HomeController: $e");
    }
  }
}
