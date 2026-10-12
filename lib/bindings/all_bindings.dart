import 'package:get/get.dart';

import '../login/controller/login_controller.dart';
import '../pages/controller/live_feed_page_controller.dart';

class LoginBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}

class LiveFeedPageBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => LiveFeedPageController());
  }
}