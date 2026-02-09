

import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/user_info_model.dart';
import 'package:flutter_app/app/backend/parse/login_parse.dart';
import 'package:flutter_app/app/controller/my_courses_controller.dart';
import 'package:flutter_app/app/controller/notification_controller.dart';
import 'package:flutter_app/app/helper/dialog_helper.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../helper/router.dart';

class LoginController extends GetxController implements GetxService {
  final LoginParser parser;
  final SessionStore sessionStore;
  final NotificationController notificationController = Get.find<NotificationController>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginController({required this.parser, required this.sessionStore});

  final MyCoursesController myCourseController =
      Get.find<MyCoursesController>();
  var context = Get.context as BuildContext;
  final WishlistStore wishlistStore = Get.find<WishlistStore>();

  Future<void> login(username, password) async {
    if (username == "") {
      showToast("Username is required", isError: true);
      return;
    }
    if (password == "") {
      showToast("Password is required", isError: true);
      return;
    }
    var param = {
      "username": username,
      "password": password,
    };
    DialogHelper.showLoading();
    print("LOGIN DEBUG: Sending request to API with username: $username");
    try {
      Response response = await parser.login(param);
      print("LOGIN DEBUG: Response statusCode: ${response.statusCode}");
      print("LOGIN DEBUG: Response body: ${response.body}");
      print("LOGIN DEBUG: Response bodyString: ${response.bodyString}");
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        print("LOGIN DEBUG: Parsed myMap: $myMap");
        // Check if token exists in expected location
        if (myMap['token'] == null) {
          print("LOGIN DEBUG: ERROR - 'token' field not found in response");
          print("LOGIN DEBUG: Available keys: ${myMap.keys.toList()}");
          // Check for alternative token locations
          if (myMap['data'] != null && myMap['data'] is Map) {
            print("LOGIN DEBUG: Found 'data' field, checking for nested token...");
            myMap = Map<String, dynamic>.from(myMap['data']);
            print("LOGIN DEBUG: Updated myMap: $myMap");
          }
        }
        parser.saveToken(myMap['token']);
        sessionStore.setToken(myMap['token']);
        wishlistStore.getWishlist();
        myCourseController.refreshData();
        
        // Check if user fields exist
        print("LOGIN DEBUG: Checking user fields...");
        print("LOGIN DEBUG: user_id: ${myMap['user_id']}");
        print("LOGIN DEBUG: user_login: ${myMap['user_login']}");
        print("LOGIN DEBUG: user_email: ${myMap['user_email']}");
        print("LOGIN DEBUG: user_display_name: ${myMap['user_display_name']}");
        
        parser.saveUser(myMap['user_id'], myMap['user_login'],
            myMap['user_email'], myMap['user_display_name']);
        sessionStore.getUser();

        DialogHelper.hideLoading();
        if (sessionStore.getCurrentCoursesId().isEmpty) {
          Get.offAllNamed(AppRouter.tabsBarRoutes);
        } else {
          Get.offNamed(AppRouter.courseDetail,
              arguments: [sessionStore.getCurrentCoursesId()]);
        }
      } else {
        DialogHelper.hideLoading();
        print("LOGIN DEBUG: Error response - statusCode: ${response.statusCode}");
        print("LOGIN DEBUG: Error body: ${response.body}");
        print("LOGIN DEBUG: Error bodyString: ${response.bodyString}");
        print("LOGIN DEBUG: Error statusText: ${response.statusText}");
        showToast(response.body?["message"] ?? "Login failed", isError: true);
      }
    } catch (e) {
      print("Login error: $e");
      DialogHelper.hideLoading();
      showToast("Error: ${e.toString()}", isError: true);
    }
  }

  Future<void> getUser() async {
    String token = parser.getToken();
    if (token == "") return;
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    Response response = await parser.getUser(payload["data"]["user"]["id"]);
    if (response.statusCode == 200) {
      UserInfoModel user = UserInfoModel.fromJson(response.body);
      parser.saveUserInfo(user);
    }
    update();
  }

  final OutlineInputBorder enabledBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(8.0),
      topRight: Radius.circular(8.0),
      bottomLeft: Radius.circular(8.0),
      bottomRight: Radius.circular(8.0),
    ),
    borderSide: BorderSide(color: Colors.grey),
  );
}
