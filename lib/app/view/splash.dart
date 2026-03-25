import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/app/controller/splash_controller.dart';
import 'package:flutter_app/app/env.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';

class SplashScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<SplashController>().initSharedData();
    _routing();
  }

  void _routing() {
    final sessionStore = Get.find<SessionStore>();
    
    Future.delayed(const Duration(seconds: 2), () {
      String token = sessionStore.getToken();
      
      if (token != "") {
        // Пайдаланушы кірген болса - басты бетке
        Get.offAllNamed(AppRouter.tabsBarRoutes);
      } else {
        // Пайдаланушы шыққан болса - логин бетіне
        Get.offAllNamed(AppRouter.getLoginRoute());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (value) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(alignment: AlignmentDirectional.center, children: [
          const Positioned(
            top: 250,
            child: Center(
              child: Text(
                Environments.appName,
                style: TextStyle(
                    color: Colors.black, 
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'bold'),
              ),
            ),
          ),
          const Positioned(
            bottom: 100,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4A6CF7),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            child: Center(
              child: Text(
                'Developed By '.tr + Environments.companyName,
                style: const TextStyle(
                    color: Colors.grey, fontFamily: 'medium'),
              ),
            ),
          ),
        ]),
      );
    });
  }
}
