import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peiboshow/global_contoller/global_controller.dart';

import '../routes/all_routes.dart';

class LaunchView extends StatefulWidget {
  const LaunchView({super.key});

  @override
  State<LaunchView> createState() => _LaunchViewState();
}

class _LaunchViewState extends State<LaunchView> {
  GlobalController globalController = Get.find<GlobalController>();
  bool _navigated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkTokenAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37373A),
      body: SizedBox.expand(
        child: Image.asset(
          "images/background_img.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> _checkTokenAndNavigate() async {
    if (_navigated) return;
    _navigated = true;
    // 获取 token 和 balconyList
    await globalController.getToken();
    if (!mounted) return;
    if (globalController.token != null && globalController.token!.isNotEmpty) {
      Get.offNamed(AllRoutes.liveFeedPage);
    } else {
      Get.offNamed(AllRoutes.login);
      // Get.to(LiveRoomsScreen());
    }
  }
}
