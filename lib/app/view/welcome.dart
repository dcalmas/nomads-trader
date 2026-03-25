import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/controller/splash_controller.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/env.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // 1. Жүйені іске қосу (SharedPrefs-ті SessionStore-ға жүктеу)
    // SplashController-ді GetX арқылы тауып, оның ішіндегі initSharedData-ны шақырамыз
    try {
      final splashController = Get.find<SplashController>();
      await splashController.initSharedData();
    } catch (e) {
      print('WelcomeScreen Init Error: $e');
    }

    // 2. Логотип көрініп тұруы үшін 2 секунд күтеміз
    Timer(const Duration(seconds: 2), () {
      final sessionStore = Get.find<SessionStore>();
      String token = sessionStore.getToken();
      
      print('WelcomeScreen: Checking token: "$token"');
      
      if (token != null && token.isNotEmpty) {
        // Егер токен болса - басты бетке (Tabs)
        Get.offAllNamed(AppRouter.tabsBarRoutes);
      } else {
        // Егер токен жоқ болса - Логин бетіне
        Get.offAllNamed(AppRouter.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              Environments.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A6CF7),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Color(0xFF4A6CF7),
            ),
          ],
        ),
      ),
    );
  }
}
