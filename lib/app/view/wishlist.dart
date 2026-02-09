import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/controller/courses_controller.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/controller/wishlish_controller.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/view/components/item-course.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:indexed/indexed.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onLogin() {
    Future.delayed(Duration.zero, () {
      Get.toNamed(AppRouter.getLoginRoute());
    });
  }

  final WishlistStore wishlistStore = Get.find<WishlistStore>();
  final HomeController homeController = Get.find<HomeController>();
  final CoursesController courseController = Get.find<CoursesController>();
  var screenWidth =
      (window.physicalSize.shortestSide / window.devicePixelRatio);
  var screenHeight =
      (window.physicalSize.longestSide / window.devicePixelRatio);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WishlistController>(builder: (value) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawerEnableOpenDragGesture: false,
        body: Stack(
          children: <Widget>[
            Indexed(
              index: 1,
              child: Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: (276 / 375) * screenWidth,
                  height: (209 / 375) * screenWidth,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          'assets/images/banner-my-course.png',
                        ),
                        fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  height: 80.0,
                  width: screenWidth,
                  // color: Colors.blue,
                  padding: EdgeInsets.fromLTRB(
                      16, MediaQuery.of(context).viewPadding.top-10, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(width: 40),
                      Text(
                        tr( LocaleKeys.wishlist_title),
                        style: const TextStyle(
                          fontFamily: 'Poppins-Medium',
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                        ),
                      ),
                      Container(width: 40),
                    ],
                  ),
                ),
                if (value.parser.getToken() != '' &&
                    wishlistStore.data.length == 0)
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    child: Text(
                      tr(LocaleKeys.dataNotFound),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                value.parser.getToken() == ''
                    ? Container(
                        width: screenWidth,
                        height: screenHeight * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: screenWidth * 0.8,
                              padding: const EdgeInsets.symmetric(
                                vertical: 30,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A6CF7),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    spreadRadius: 0,
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.lock_outline,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    tr(LocaleKeys.needLogin),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF9F0A),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 48,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: onLogin,
                                    child: Text(
                                      tr(LocaleKeys.login),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => value.refreshData(),
                          child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100), // Nav bar space
                              controller: value.scrollController,
                              itemCount: wishlistStore.data.length +
                                  (value.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == wishlistStore.data.length) {
                                  return const Center(
                                      child: SizedBox(
                                    width: 20.0,
                                    height: 20.0,
                                          child: CircularProgressIndicator(),
                                  ));
                                } else if (index < wishlistStore.data.length) {
                                  return ItemCourse(
                                      item: wishlistStore.data[index],
                                      courseDetailParser: Get.find(),
                                      onToggleWishlist: () async => {
                                            await value.onToggleWishlist(
                                                wishlistStore.data[index]),
                                            homeController.refreshScreen(),
                                            courseController.refreshScreen(),
                                          },
                                    hideCategory: true,
                                          );
                                } else {
                                  return Container();
                                }
                              }),
                        ),
                      ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
