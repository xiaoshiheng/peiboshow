import 'package:get/get.dart';

import '../bindings/all_bindings.dart';
import '../launch/launch_view.dart';
import '../login/login_view.dart';

class AllRoutes {
  static const String launch = "/";
  static const String login = "/login";


  static final List<GetPage> getPage = [
    GetPage(
      name: launch,
      page: () => LaunchView(),
    ),
    GetPage(
      name: login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
  ];
}