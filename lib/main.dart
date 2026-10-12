import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:peiboshow/login/login_view.dart';
import 'package:peiboshow/routes/all_routes.dart';
import 'global_contoller/global_controller.dart';
import 'services/netease_live_service.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      initialBinding: BindingsBuilder(() {
        Get.put(GlobalController(), permanent: true);
      }),
      initialRoute: '/',
      getPages: AllRoutes.getPage,
      builder: FlutterSmartDialog.init(),
      navigatorObservers: [FlutterSmartDialog.observer],
    );
  }
}
