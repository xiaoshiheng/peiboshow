import 'package:get/get.dart';

import 'package:get/get.dart';
import 'package:meta/meta.dart';

import '../utils/nsuserdefault.dart';

class GlobalController extends GetxController {
  String? token;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getToken();
  }

  ///获取本地保存的token和用户信息
  Future<void> getToken() async {
    NSUserDefault userDefault = await NSUserDefault.getInstance();
    token = userDefault.getValueForKey("token");
  }

  ///保存token和用户信息到本地
  Future<void> saveToken(String token) async {
    NSUserDefault userDefault = await NSUserDefault.getInstance();
    await userDefault.setString("token", token);
    this.token = token;
  }
}