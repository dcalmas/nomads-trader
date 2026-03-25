
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

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginController({required this.parser, required this.sessionStore});

  // Safely access controllers only if they are registered
  NotificationController? get notificationController => Get.isRegistered<NotificationController>() ? Get.find<NotificationController>() : null;
  WishlistStore? get wishlistStore => Get.isRegistered<WishlistStore>() ? Get.find<WishlistStore>() : null;
  MyCoursesController? get myCourseController => Get.isRegistered<MyCoursesController>() ? Get.find<MyCoursesController>() : null;

  var context = Get.context as BuildContext;

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
    try {
      Response response = await parser.login(param);
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        if (myMap['token'] == null) {
          if (myMap['data'] != null && myMap['data'] is Map) {
            myMap = Map<String, dynamic>.from(myMap['data']);
          }
        }
        
        // Save token and info
        parser.saveToken(myMap['token']);
        sessionStore.setToken(myMap['token']);
        
        // Safely refresh data
        wishlistStore?.getWishlist();
        myCourseController?.refreshData();
        
        parser.saveUser(myMap['user_id'], myMap['user_login'],
            myMap['user_email'], myMap['user_display_name']);
        sessionStore.getUser();

        DialogHelper.hideLoading();
        
        // Navigate
        if (sessionStore.getCurrentCoursesId().isEmpty) {
          Get.offAllNamed(AppRouter.tabsBarRoutes);
        } else {
          Get.offNamed(AppRouter.courseDetail,
              arguments: [sessionStore.getCurrentCoursesId()]);
        }
      } else {
        DialogHelper.hideLoading();
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
