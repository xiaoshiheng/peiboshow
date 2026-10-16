import 'package:get/get.dart';

import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:peiboshow/api_request/api_request.dart';

import '../api_request/api_request_client.dart';
import '../models/user_model.dart';
import '../utils/nsuserdefault.dart';

class GlobalController extends GetxController {
  String? token;
  UserModel? userModel;

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
    final map = userDefault.getMapValueForKey("userModel");
    if (map != null) {
      userModel = UserModel.fromJson(Map<String, dynamic>.from(map));
    }
  }

  ///保存token和用户信息到本地
  Future<void> saveToken(String token, UserModel? userModel) async {
    NSUserDefault userDefault = await NSUserDefault.getInstance();
    await userDefault.setString("token", token);
    if (userModel != null) {
      await userDefault.setMap("userModel", userModel.toJson());
    }
    this.token = token;
    this.userModel = userModel;
  }

  ///退出登录，清除本地token和用户信息
  Future<void> logout() async {
    bool ok = await request(() async {
      await requestClient.get("/wx-zhibo-room/delAdmin");
      return true;
    });
    if (!ok) {
      return;
    }
    NSUserDefault userDefault = await NSUserDefault.getInstance();
    await userDefault.removeValueForKey("token");
    await userDefault.removeValueForKey("userModel");
    token = null;
    userModel = null;
  }
}