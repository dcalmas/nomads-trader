import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter_app/app/controller/courses_controller.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/controller/my_courses_controller.dart';
import 'package:flutter_app/app/controller/my_profile_controller.dart';
import 'package:flutter_app/app/controller/notification_controller.dart';
import 'package:flutter_app/app/controller/payment_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/courses.dart';
import 'package:flutter_app/app/view/home.dart';
import 'package:flutter_app/app/view/my_courses.dart';
import 'package:flutter_app/app/view/my_profile.dart';
import 'package:flutter_app/app/view/wishlist.dart';
import 'package:get/get.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import '../../l10n/locale_keys.g.dart';

class TabScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  TabScreen({super.key});

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _currentIndex = 0;

  final List<Widget> _tabViews = [
    HomeScreen(),
    const CoursesScreen(),
    const MyCoursesScreen(),
    const WishlistScreen(),
    MyProfileScreen()
  ];

  // Controllers
  final CoursesController controllerCourse =
  Get.put(CoursesController(parser: Get.find()));
  final HomeController homeController =
  Get.put(HomeController(parser: Get.find()));
  final MyCoursesController myCoursesController =
  Get.put(MyCoursesController(parser: Get.find()));
  final PaymentController paymentController =
  Get.put(PaymentController(parser: Get.find()));
  final NotificationController notificationController =
  Get.put(NotificationController(parser: Get.find()));
  final MyProfileController myProfileController =
  Get.put(MyProfileController(parser: Get.find()));

  // Tab data
  final List<Map<String, dynamic>> _tabItems = [
    {
      'icon': 'assets/images/icon-tab/icon-tab-home.png',
      'labelKey': LocaleKeys.bottomNavigation_home,
    },
    {
      'icon': 'assets/images/icon-tab/icon-tab-coures.png',
      'labelKey': LocaleKeys.bottomNavigation_courses,
    },
    {
      'icon': 'assets/images/icon-tab/icon-my-course.png',
      'labelKey': LocaleKeys.bottomNavigation_myCourse,
    },
    {
      'icon': 'assets/images/icon-tab/icon-wishlist.png',
      'labelKey': LocaleKeys.bottomNavigation_wishlist,
    },
    {
      'icon': 'assets/images/icon-tab/icon-profile.png',
      'labelKey': LocaleKeys.bottomNavigation_profile,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _tabController = TabController(
            length: 5,
            vsync: this,
            initialIndex: 0,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      homeController.getOverview();
    }
    if (index == 2) {
      myCoursesController.refreshData();
    }
    setState(() {
      _currentIndex = index;
      _tabController?.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true, // ✅ Content extends behind nav bar for glass blur
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: _tabViews,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildIOSGlassDock(context, screenWidth),
      ),
    );
  }

  // =========================
  // iOS GLASS DOCK (works even on white backgrounds)
  // =========================

  Widget _buildIOSGlassDock(BuildContext context, double screenWidth) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Shadow outside blur container
            Container(
              height: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),

            // The actual glass surface
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isIOS ? 35 : 28,
                sigmaY: isIOS ? 35 : 28,
              ),
              child: Container(
                height: 78,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  // ✅ Glass blur transparent effect
                  color: Colors.white.withOpacity(isIOS ? 0.40 : 0.45),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.55),
                    width: 0.9,
                  ),
                ),
                child: Stack(
                  children: [
                    // Top highlight (gives glass)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.26),
                                Colors.white.withOpacity(0.10),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.50, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom tint (depth)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.07),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.70],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ✅ Noise overlay — makes "glass" visible on white backgrounds
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: 0.06,
                          child: CustomPaint(
                            painter: _NoisePainter(),
                          ),
                        ),
                      ),
                    ),

                    // Items
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _buildNavItems(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // ITEMS (GRAY/BLACK + ACTIVE UNDERLINE)
  // =========================

  List<Widget> _buildNavItems(BuildContext context) {
    return List.generate(
      _tabItems.length,
          (index) => _buildNavItem(
        context: context,
        index: index,
        iconPath: _tabItems[index]['icon'] as String,
        labelKey: _tabItems[index]['labelKey'] as String,
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String iconPath,
    required String labelKey,
  }) {
    final bool isActive = _currentIndex == index;

    final Color iconColor = isActive
        ? Colors.black.withOpacity(0.88)
        : Colors.black.withOpacity(0.48);

    final Color textColor = isActive
        ? Colors.black.withOpacity(0.82)
        : Colors.black.withOpacity(0.44);

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                scale: isActive ? 1.04 : 1.0,
                child: Image.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
                child: Text(
                  tr(labelKey).toString(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: isActive ? 18 : 6,
                height: 3,
                decoration: BoxDecoration(
                  color: isActive
                      ? ThemeProvider.secondaryAppColor.withOpacity(0.85)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: ThemeProvider.secondaryAppColor.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// Noise painter (tiny dots)
// =========================
class _NoisePainter extends CustomPainter {
  final math.Random _r = math.Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black.withOpacity(0.20)
      ..isAntiAlias = false;

    // ~900 dots
    for (int i = 0; i < 900; i++) {
      final dx = _r.nextDouble() * size.width;
      final dy = _r.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(dx, dy, 1, 1), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
