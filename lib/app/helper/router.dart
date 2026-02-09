import 'package:flutter_app/app/backend/binding/course_detail_binding.dart';
import 'package:flutter_app/app/backend/binding/finish_learning_binding.dart';
import 'package:flutter_app/app/backend/binding/home_binding.dart';
import 'package:flutter_app/app/backend/binding/learning_binding.dart';
import 'package:flutter_app/app/backend/binding/login_binding.dart';
import 'package:flutter_app/app/backend/binding/notification_binding.dart';
import 'package:flutter_app/app/backend/binding/register_binding.dart';
import 'package:flutter_app/app/backend/binding/review_binding.dart';
import 'package:flutter_app/app/backend/binding/search_course_binding.dart';
import 'package:flutter_app/app/backend/binding/splash_binding.dart';
import 'package:flutter_app/app/backend/binding/tabs_binding.dart';

import 'package:flutter_app/app/view/welcome.dart'; // ✅ WELCOME
import 'package:flutter_app/app/view/course_detail.dart';
import 'package:flutter_app/app/view/finish_learning.dart';
import 'package:flutter_app/app/view/forgot_password.dart';
import 'package:flutter_app/app/view/home.dart';
import 'package:flutter_app/app/view/instructor_detail.dart';
import 'package:flutter_app/app/view/learing.dart';
import 'package:flutter_app/app/view/login.dart';
import 'package:flutter_app/app/view/notification.dart';
import 'package:flutter_app/app/view/register.dart';
import 'package:flutter_app/app/view/review.dart';
import 'package:flutter_app/app/view/search-course.dart';
import 'package:flutter_app/app/view/tabs.dart';

import 'package:get/get.dart';

import '../backend/binding/forgot_password_binding.dart';
import '../backend/binding/intructor_detail_binding.dart';
import '../backend/binding/language_binding.dart';
import '../view/components/profile/settings/delete-account.dart';
import '../view/components/profile/settings/general.dart';
import '../view/components/profile/settings/language.dart';
import '../view/components/profile/settings/password.dart';

class AppRouter {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String tabsBarRoutes = '/tabs';
  static const String home = '/home';
  static const String login = '/login';
  static const String forgotPassword = '/forgotPassword';
  static const String register = '/register';
  static const String courseDetail = '/course_detail';
  static const String learning = '/learning';
  static const String finishLearning = '/finishLearning';
  static const String searchCourse = '/searchCourse';
  static const String intructorDetail = '/intructorDetail';
  static const String notification = '/notification';
  static const String review = '/review';
  static const String language = '/language';
  static const String general = '/general';
  static const String password = '/password';
  static const String delete = '/delete';

  // Route getter methods
  static String getCourseDetailRoute() => courseDetail;
  static String getLoginRoute() => login;
  static String getRegisterRoute() => register;
  static String getForgotPasswordRoute() => forgotPassword;
  static String getTabsRoute() => tabsBarRoutes;
  static String getHomeRoute() => home;
  static String getLearningRoute() => learning;
  static String getFinishLearningRoute() => finishLearning;
  static String getSearchCourseRoute() => searchCourse;
  static String getInstructorDetailRoute() => intructorDetail;
  static String getNotificationRoute() => notification;
  static String getReviewRoute() => review;

  static List<GetPage> routes = [
    /// 🚀 APP STARTS HERE
    GetPage(
      name: splash,
      page: () => const WelcomeScreen(),
      binding: SplashBinding(),
    ),

    /// 🧭 MAIN TABS
    GetPage(
      name: tabsBarRoutes,
      page: () => TabScreen(),
      binding: TabsBinding(),
    ),

    /// 🏠 HOME
    GetPage(
      name: home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),

    /// 🔐 AUTH
    GetPage(
      name: login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),

    /// 📚 COURSES
    GetPage(
      name: courseDetail,
      page: () => CourseDetailScreen(),
      binding: CourseDetailBinding(),
      preventDuplicates: false,
    ),
    GetPage(
      name: learning,
      page: () => LearningScreen(),
      binding: LearningBinding(),
    ),
    GetPage(
      name: finishLearning,
      page: () => FinishLearningScreen(),
      binding: FinishLearningBinding(),
    ),
    GetPage(
      name: searchCourse,
      page: () => SearchCourseScreen(),
      binding: SearchCourseBinding(),
    ),

    /// 👨‍🏫 INSTRUCTOR
    GetPage(
      name: intructorDetail,
      page: () => InstructorDetailScreen(),
      binding: InstructorDetailBinding(),
      preventDuplicates: false,
    ),

    /// 🔔 NOTIFICATIONS
    GetPage(
      name: notification,
      page: () => NotificationScreen(),
      binding: NotificationBinding(),
    ),

    /// ⭐ REVIEW
    GetPage(
      name: review,
      page: () => ReviewScreen(),
      binding: ReviewBinding(),
    ),

    /// ⚙️ SETTINGS
    GetPage(
      name: language,
      page: () => MultiLanguage(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: general,
      page: () => GeneralAccount(),
    ),
    GetPage(
      name: password,
      page: () => Password(),
    ),
    GetPage(
      name: delete,
      page: () => DeleteAccount(),
    ),
  ];
}
