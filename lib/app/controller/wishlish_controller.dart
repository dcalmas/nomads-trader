
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/backend/parse/wishlist_parse.dart';
import 'package:flutter_app/app/helper/dialog_helper.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/locale_keys.g.dart';
import '../helper/router.dart';

class WishlistController extends GetxController implements GetxService {
  final WishlistParser parser;

  bool apiCalled = false;
  bool isLoading = false;
  bool isLoadingMore = false;

  final ScrollController scrollController = ScrollController();
  final WishlistStore wishlistStore = Get.find<WishlistStore>();

  WishlistController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  Future<void> refreshData() async {
    await getData();
  }

  // Fetch courses from WishlistStore
  Future<void> getData() async {
    if (parser.getToken().isEmpty) return;
    
    isLoading = true;
    update();
    
    await wishlistStore.getWishlist();
    
    isLoading = false;
    apiCalled = true;
    update();
  }

  Future<void> onToggleWishlist(CourseModel item) async {
    var context = Get.context as BuildContext;
    if (parser.getToken() == "") {
      Alert(
        context: context,
        title: tr(LocaleKeys.alert_notLoggedIn),
        desc: tr(LocaleKeys.alert_loggedIn),
        buttons: [
          DialogButton(
            color: Colors.red,
            child: Text(
              tr(LocaleKeys.alert_cancel),
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => {Navigator.pop(context)},
          ),
          DialogButton(
            child: Text(
              tr(LocaleKeys.alert_btnLogin),
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => {
              Navigator.pop(context),
              Get.toNamed(AppRouter.login)
            },
          ),
        ],
      ).show();
    } else {
      DialogHelper.showLoading();
      bool success = await wishlistStore.toggleWishlist(item);
      DialogHelper.hideLoading();
      if (success) {
        update(); // Refresh UI
      }
    }
  }

  Future<void> launchInBrowser(String link) async {
    var url = Uri.parse(link);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
