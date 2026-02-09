
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/courses_controller.dart';
import 'package:flutter_app/app/controller/my_courses_controller.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../helper/shared_pref.dart';

class LanguageController extends GetxController implements GetxService {
  final SharedPreferencesManager sharedPreferencesManager;
  String currentKeyLanguage = '';
  LanguageController({required this.sharedPreferencesManager});

  var _listLanguage = [
    {"key": "kk", "countryCode": "KZ", "value": "Қазақша", "isActive": true},
    {"key": "ru", "countryCode": "RU", "value": "Русский", "isActive": false},
    {"key": "en", "countryCode": "US", "value": "English", "isActive": false},
  ];

  List<dynamic> get listLanguage => _listLanguage;

  handleChoiceLanguage(key) {
    if(key == ''){
      key = 'kk';
    }
    currentKeyLanguage = key;
    var dataRaw = _listLanguage.map((e) {
      e['isActive'] = false;
      return e;
    }).toList();
    var data = dataRaw.map((element) {
      if (element['key'] == key) {
        element['isActive'] = true;
        return element;
      }
      return element;
    }).toList();
    _listLanguage = data;

    Map currentLanguage = _listLanguage.firstWhere((element) => element['key'] == key);
    update();
    refresh();
    return currentLanguage;
  }

  handleUpdate(currentLanguage) async {
    var context = Get.context as BuildContext;
    var newLocale =
        Locale(currentLanguage['key'], currentLanguage['countryCode']);

    await context.setLocale(newLocale);
    EasyLocalization.of(context)?.setLocale(newLocale);
    sharedPreferencesManager.putString('language', currentLanguage['key']);
    Get.updateLocale(newLocale);
    await context.deleteSaveLocale();
    CoursesController controller = Get.find();
    MyCoursesController myCoursesController = Get.find();
    myCoursesController.onInit();
    controller.handleGetOption();
    Alert(
      context: context,
      desc: tr(LocaleKeys.changeLanguageSuccess),
      buttons: [
        DialogButton(
          child: Text(
            tr(LocaleKeys.alert_ok),
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () => {Navigator.pop(context)},
        ),
      ],
    ).show();
    update();
    refresh();
  }
}
