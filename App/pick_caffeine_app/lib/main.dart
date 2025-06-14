import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/view/admin/admin_statistics.dart';
import 'package:pick_caffeine_app/view/login/login.dart';
import 'package:pick_caffeine_app/vm/changjun/customer_tabbar.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
import 'package:pick_caffeine_app/vm/kwonhyoung/kwonhyoung_controller.dart';
import 'package:pick_caffeine_app/vm/seoyun/vm_handler.dart';
import 'package:pick_caffeine_app/vm/seoyun/vm_image_handler.dart';

void main() {
  // ------------------- //
  // ChangJun : vm Temp & Tabbar
  Get.put(JunTemp());
  Get.put(CustomerTabbar());
  // ------------------- //
  Get.put(VmHandlerTemp());
  Get.put(InquiryController());
  Get.put(DeclarationController());
  Get.put(Order());
  Get.put(VmImageHandler());
  Get.put(Vmgamseong()..checkLocationPermission());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    if (Device.get().isPhone) {
      //Do some notch business
      return GetMaterialApp(
        title: 'Flutter Demo',

        // -------------------------------- //
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: Login(),
      );
    }
    return GetMaterialApp(
      //         calender 한글화        //
      // 기본 언어 설정
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Login(),
    );
  }
}
