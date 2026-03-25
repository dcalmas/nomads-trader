import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/backend/models/lesson-model.dart';
import 'package:flutter_app/app/backend/parse/course_detail_parse.dart';
import 'package:flutter_app/app/helper/dialog_helper.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CourseDetailController extends GetxController {
  final CourseDetailParser parser;
  final courseStore = locator<CourseStore>();
  String courseId = "";
  bool apiCalled = false;

  bool haveData = false;

  String title = '';
  bool isLoading = false;
  CourseModel _course = CourseModel();
  CourseModel get course => _course;
  CourseDetailController({required this.parser});
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  double rating = 5;
  dynamic review;
  String reviewMessage = "";
  int sectionId = 0;
  bool callAgainRoute=false;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments.isNotEmpty) {
      courseId = Get.arguments[0].toString();
      getData();
    }
  }
  
  handleGetIndexLesson(){
    if (course.sections == null) return 0;
    ItemLesson? itemRedirect = ItemLesson();
    int i =0;
    for (var item in course.sections!) {
      itemRedirect = item.items?.firstWhere(
            (x) => x.status != 'completed',
        orElse: () => ItemLesson(),
      );
      if (itemRedirect?.id != null) {
        break;
      }
      i++;
    }
    return i;
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  void start() {
    DialogHelper.showLoading();
    Future.delayed(const Duration(seconds: 1),(){
      if (_course.sections != null &&
          _course.sections!.isNotEmpty &&
          _course.sections![0].items!.isNotEmpty) {
        ItemLesson? itemRedirect;
        for (var item in _course.sections!) {
          itemRedirect = item.items?.firstWhere(
                (x) => x.status != 'completed',
            orElse: () => ItemLesson(),
          );
          sectionId = item.id!;
          if (itemRedirect?.id != null) {
            break;
          }
        }
        DialogHelper.hideLoading();
        onNavigateLearning(
            itemRedirect?.id != null
                ? itemRedirect
                : _course.sections![0].items![0],
            0);
      } else {
        DialogHelper.hideLoading();
      }
    });
  }

  void onNavigateLearning(item, index) {
    Get.toNamed(AppRouter.learning,
        arguments: [item, index, courseId, sectionId]);
  }

  Future<void> onStartCourse() async {
    try {
      final response = await parser.enroll(courseId);
      if (response.statusCode == 200) {
        start();
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
    }
  }

  Future<void> onRetake() async {
    try {
      DialogHelper.showLoading();
      final response = await parser.enroll(courseId);
      Future.delayed(const Duration(seconds: 1),(){
        DialogHelper.hideLoading();
        if (response.statusCode == 200) {
          getData();
          start();
        }
      });
    } catch (e) {
      print(e);
      DialogHelper.hideLoading();
    }
  }

  Future<void> onEnroll() async {
    try {
      var context = Get.context as BuildContext;
      if (parser.getToken() == "") {
        Alert(
          context: context,
          title: tr(LocaleKeys.alert_notLoggedIn),
          desc: tr(LocaleKeys.alert_loggedIn),
          buttons: [
            DialogButton(
              color: Colors.red,
              child: Text(tr(LocaleKeys.alert_cancel), style: TextStyle(color: Colors.white)),
              onPressed: () => {Navigator.pop(context)},
            ),
            DialogButton(
              child: Text(tr(LocaleKeys.alert_btnLogin), style: TextStyle(color: Colors.white)),
              onPressed: () => {
                Navigator.pop(context),
                Get.toNamed(AppRouter.login)
              },
            ),
          ],
        ).show();
      } else {
        final response = await parser.enroll(courseId);
        if (response.statusCode == 200) {
          start();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> refreshData() async {
    await getData();
  }

  Future<void> getData() async {
    isLoading = true;
    update();
    try {
      parser.setOverview(courseId);
      final response = await parser.getDetailCourse(courseId);
      if (response.statusCode == 200) {
        CourseModel courseTemp = CourseModel.fromJson(response.body);
        _course = courseTemp;
        courseStore.setDetail(courseTemp);
        getRating(3);
      }
    } catch (e) {
      print("Error fetching course detail: $e");
    } finally {
      isLoading = false;
      update();
    }
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
            child: Text(tr(LocaleKeys.alert_cancel), style: TextStyle(color: Colors.white)),
            onPressed: () => {Navigator.pop(context)},
          ),
          DialogButton(
            child: Text(tr(LocaleKeys.alert_btnLogin), style: TextStyle(color: Colors.white)),
            onPressed: () => {
              Navigator.pop(context),
              Get.toNamed(AppRouter.login)
            },
          ),
        ],
      ).show();
    } else {
      DialogHelper.showLoading();
      try {
        final WishlistStore wishlistStore = Get.find<WishlistStore>();
        await wishlistStore.toggleWishlist(item);
        // Important: Notify the UI that MobX state has changed
        update(); 
      } catch (e) {
        print("Wishlist toggle error: $e");
      } finally {
        DialogHelper.hideLoading();
      }
    }
  }

  Future<void> getRating(int? per_page) async {
    try {
      final response = await parser.getRating(courseId, per_page);
      if (response.statusCode == 200 && response.body is Map) {
        review = response.body["data"];
        reviewMessage = response.body["message"];
        update();
      } else {
        print("Review API returned non-JSON response or error code");
      }
    } catch (e) {
      print("Exception in getRating: $e");
    }
  }

  Future<void> submitRating() async {
    var context = Get.context as BuildContext;
    try {
      if (titleController.text == "") {
        showToast(tr(LocaleKeys.singleCourse_reviewTitleEmpty), isError: true);
        return;
      }
      if (contentController.text == "") {
        showToast(tr(LocaleKeys.singleCourse_reviewContentEmpty), isError: true);
        return;
      }

      var param = {
        "id": courseId,
        "title": titleController.text,
        "rate": rating.toString(),
        "content": contentController.text,
      };
      context.loaderOverlay.show();
      final response = await parser.createRating(param);
      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        getRating(3);
        titleController.text = "";
        contentController.text = "";
        showToast(response.body["message"] ?? "Review submitted");
        update();
      } else {
        showToast(response.body["message"] ?? "Failed to submit review", isError: true);
      }
    } catch (e) {
      print(e);
      context.loaderOverlay.hide();
    }
  }
}
