import 'dart:convert';

import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/backend/models/response_v2.dart';
import 'package:flutter_app/app/env.dart';
import 'package:flutter_app/app/util/constant.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'wishlist_store.g.dart';

class WishlistStore = _WishlistStore with _$WishlistStore;

abstract class _WishlistStore with Store {
  ApiService apiService = ApiService(appBaseUrl: Environments.apiBaseURL);

  _WishlistStore();

  @observable
  ObservableList<CourseModel> data = ObservableList<CourseModel>.of([]);
  
  @observable
  bool isLoading = false;

  @action
  Future<void> getWishlist() async {
    isLoading = true;
    String token = await getToken();
    if (token.isEmpty) {
      data.clear();
      isLoading = false;
      return;
    }

    var body = {
      "page": "1",
      "per_page": "1000",
      "optimize": "true",
    };
    
    try {
      var response = await apiService.getPrivate(AppConstants.getWishList, token, body);
      if (response.statusCode == 200) {
        String temp = jsonEncode(response.body);
        dynamic temp2 = jsonDecode(temp);
        ResponseV2 resV2 = ResponseV2.fromJson(temp2);
        
        List<CourseModel> lstTemp = [];
        resV2.data?.forEach((item) {
          CourseModel course = CourseModel.fromJson(item);
          lstTemp.add(course);
        });
        
        data.clear();
        data.addAll(lstTemp);
      }
    } catch (e) {
      print("WishlistStore Error: $e");
    } finally {
      isLoading = false;
    }
  }

  @action
  void setWishlist(List<CourseModel> items) {
    data.clear();
    data.addAll(items);
  }

  @action
  Future<bool> toggleWishlist(CourseModel item) async {
    String token = await getToken();
    if (token.isEmpty) return false;

    var param = {
      "id": item.id,
    };
    
    try {
      var response = await apiService.postPrivate(AppConstants.toggleWishlist, param, token);
      if (response.statusCode == 200) {
        await getWishlist();
        return true;
      }
    } catch (e) {
      print("Toggle Wishlist Error: $e");
    }
    return false;
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? "";
  }
}
