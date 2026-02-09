import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/parse/my_profile_parse.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';

import '../../../controller/profile_controller.dart';
import '../../../env.dart';

typedef OnNavigateCallback = void Function(int page);

class Profile extends StatefulWidget {
  final MyProfileParser myProfileParser;
  final ProfileController profileController;
  final OnNavigateCallback goToPage;
  final OnNavigateCallback goBack;

  @override
  State<Profile> createState() => _Profile();

  Profile(
      {required this.myProfileParser,
      super.key,
      required this.goToPage,
      required this.goBack,
      required this.profileController});
}

class _Profile extends State<Profile> {
  @override
  void initState() {
    String? user = widget.myProfileParser.getUserInfo();
    if (user != null) {
      widget.profileController.refreshDataUser(jsonDecode(user));
    }

    super.initState();
  }

  void onLogin() {
    Future.delayed(Duration.zero, () {
      Get.toNamed(AppRouter.getLoginRoute());
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var screenWidth =
      (window.physicalSize.shortestSide / window.devicePixelRatio);
  var screenHeight =
      (window.physicalSize.longestSide / window.devicePixelRatio);

  @override
  Widget build(BuildContext context) {
    final value = widget.profileController;
    final isAuthorized = widget.myProfileParser.getToken() != '';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawerEnableOpenDragGesture: false,
      body: Column(
        children: [
          // Top padding
          Container(
            height: MediaQuery.of(context).viewPadding.top,
          ),
          // Title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              tr(LocaleKeys.profile_title),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          // Profile header row
          GestureDetector(
            onTap: isAuthorized ? null : onLogin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    child: isAuthorized
                        ? value.userInfo.avatar_url != ""
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  value.userInfo.avatar_url,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/default-user-avatar.jpg',
                                fit: BoxFit.cover,
                              )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFF4A6CF7),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isAuthorized)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                value.userInfo.name ??
                                    (value.userInfo.description ?? ''),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (value.userInfo.email != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      value.userInfo.email ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          )
                        else
                          const Text(
                            "Вход/Регистрация",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Chevron
                  const Icon(
                    Ionicons.chevron_forward_outline,
                    size: 20,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          // Settings list
          Expanded(
            child: ListView(
              children: [
                // General settings
                _buildSettingsItem(
                  icon: Feather.settings,
                  title: tr(LocaleKeys.settings_general),
                  iconColor: const Color(0xFF4A6CF7),
                  onTap: () => Get.toNamed(AppRouter.general),
                ),
                // Password settings
                _buildSettingsItem(
                  icon: Feather.lock,
                  title: tr(LocaleKeys.settings_password),
                  iconColor: const Color(0xFF4A6CF7),
                  onTap: () => Get.toNamed(AppRouter.password),
                ),
                // Language settings
                _buildSettingsItem(
                  icon: Ionicons.language,
                  title: tr(LocaleKeys.language),
                  iconColor: const Color(0xFF4A6CF7),
                  onTap: () => Get.toNamed(AppRouter.language),
                ),
                // Delete account
                _buildSettingsItem(
                  icon: Feather.trash_2,
                  title: tr(LocaleKeys.settings_deleteAccount),
                  iconColor: const Color(0xFF4A6CF7),
                  onTap: () => Get.toNamed(AppRouter.delete),
                ),
              ],
            ),
          ),
          // Version info
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              LocaleKeys.profile_version,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ).tr(args: [Environments.appVersion, Environments.appBuild]),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: iconColor,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Chevron
                const Icon(
                  Ionicons.chevron_forward_outline,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        // Divider
        Container(
          height: 1,
          color: Colors.grey.shade200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }
}
