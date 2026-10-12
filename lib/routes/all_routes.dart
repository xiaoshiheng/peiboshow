import 'package:get/get.dart';

import '../bindings/all_bindings.dart';
import '../launch/launch_view.dart';
import '../login/login_view.dart';
import '../pages/live_feed_page.dart';

class AllRoutes {
  static const String launch = "/";
  static const String login = "/login";
  static const String liveFeedPage = "/liveFeedPage";

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
    GetPage(
      name: liveFeedPage,
      page: () => LiveFeedPage(),
      binding: LiveFeedPageBinding(),
    ),

  ];
}