import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/controller/language_controller.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/constant.dart';
import 'package:flutter_app/app/util/init.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Қате болса консольға да, экранға да көрсетеміз
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            'FLUTTER ERROR:\n\n${details.exceptionAsString()}\n\n${details.stack ?? ""}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  };

  await runZonedGuarded(() async {
    // 1) Localization init
    await EasyLocalization.ensureInitialized();

    // 2) Orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // 3) DI / bindings
    await MainBinding().dependencies();
    setupLocator();

    // 4) Stores (бір рет)
    final sessionStore = SessionStore();
    final wishlistStore = WishlistStore();

    if (!Get.isRegistered<SessionStore>()) {
      Get.put<SessionStore>(sessionStore, permanent: true);
    }
    if (!Get.isRegistered<WishlistStore>()) {
      Get.put<WishlistStore>(wishlistStore, permanent: true);
    }

    // ✅ ЕҢ МАҢЫЗДЫСЫ: runApp-ты бірінші жібереміз!
    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('kk', 'KZ'),
          Locale('ru', 'RU'),
          Locale('en', 'US'),
        ],
        fallbackLocale: const Locale('kk', 'KZ'),
        path: 'assets/translations',
        child: MultiProvider(
          providers: [
            Provider<SessionStore>.value(value: sessionStore),
          ],
          child: const MyApp(),
        ),
      ),
    );
  }, (error, stack) async {
    debugPrint('ZONED ERROR: $error');
    debugPrint('$stack');
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _localeApplied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localeApplied) return;

    // ⚠️ LanguageController табылмаса — ErrorWidget экранға шығарып береді
    final languageController = Get.find<LanguageController>();

    final key =
        languageController.sharedPreferencesManager.getString("language") ?? 'kk';

    final currentLanguage = languageController.handleChoiceLanguage(key);
    final currentLocale = Locale(
      currentLanguage['key'] as String,
      currentLanguage['countryCode'] as String,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // ✅ Locale 1 рет қою
      if (context.locale != currentLocale) {
        await context.setLocale(currentLocale);
      }
    });

    _localeApplied = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: GlobalLoaderOverlay(
        child: GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
          initialRoute: AppRouter.splash,
          getPages: AppRouter.routes,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            fontFamily: GoogleFonts.montserrat().fontFamily,
            textTheme: GoogleFonts.montserratTextTheme(
              Theme.of(context).textTheme,
            ),
            primaryTextTheme: GoogleFonts.montserratTextTheme(
              Theme.of(context).primaryTextTheme,
            ),
          ),
        ),
      ),
    );
  }
}
