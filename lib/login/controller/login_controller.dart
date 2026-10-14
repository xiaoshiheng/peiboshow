import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../../api_request/api_exception.dart';
import '../../api_request/api_request.dart';
import '../../api_request/api_request_client.dart';
import '../../global_contoller/global_controller.dart';
import '../../models/user_model.dart';
import '../../routes/all_routes.dart';

class LoginController extends GetxController {
  GlobalController globalController = Get.find<GlobalController>();
  /// 验证码倒计时总时长(秒)
  static const int _countdownSeconds = 60;

  /// 手机号输入控制器
  final TextEditingController phoneController = TextEditingController();

  /// 验证码输入控制器
  final TextEditingController codeController = TextEditingController();

  /// 是否正在登录
  final RxBool isLoading = false.obs;

  /// 是否正在发送验证码
  final RxBool isSendingCode = false.obs;

  /// 验证码倒计时剩余秒数，为 0 表示可重新获取
  final RxInt countdown = 0.obs;

  Timer? _timer;

  /// 倒计时是否进行中
  bool get isCountingDown => countdown.value > 0;

  /// 手机号格式校验(中国大陆 11 位手机号)
  bool get isPhoneValid =>
      RegExp(r'^1[3-9]\d{9}$').hasMatch(phoneController.text.trim());

  /// 手机号校验，校验通过返回 null，否则返回错误提示
  String? validatePhone() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      return '请输入手机号';
    }
    if (!isPhoneValid) {
      return '请输入正确的手机号';
    }
    return null;
  }

  /// 手机号 + 验证码校验，校验通过返回 null，否则返回错误提示
  String? validate() {
    final phoneError = validatePhone();
    if (phoneError != null) {
      return phoneError;
    }
    final code = codeController.text.trim();
    if (code.isEmpty) {
      return '请输入验证码';
    }
    if (code.length < 4) {
      return '请输入正确的验证码';
    }
    return null;
  }

  /// 获取验证码事件
  Future<void> sendCode() async {
    // 倒计时进行中，忽略重复点击
    if (isCountingDown || isSendingCode.value) {
      return;
    }

    final phoneError = validatePhone();
    if (phoneError != null) {
      return;
    }

    isSendingCode.value = true;
    try {
      // TODO: 接入真实获取验证码接口(短信/云信等)，成功后再启动倒计时
      // debugPrint('获取验证码，手机号: ${phoneController.text.trim()}');

      request(()async{
        dynamic data = await requestClient.get("/loginCode",queryParameters: {"mobile":phoneController.text,"vcode":""});
        print(data);
      },onError: (exception){
        if(exception.code == 10000 || exception.code == 10001){
          SmartDialog.showNotify(msg: exception.message ?? ApiException.unknownException, notifyType: NotifyType.success);
        }else{
          countdown.value = 0;
          SmartDialog.showNotify(msg: exception.message ?? ApiException.unknownException, notifyType: NotifyType.error);
        }
        return true;
      });
      _startCountdown();
    } finally {
      isSendingCode.value = false;
    }
  }

  /// 登录事件
  Future<void> login() async {
    // TODO: 暂时保留登录逻辑，后续接入真实登录（网络请求 / 保存登录态 / 页面跳转）
    debugPrint('登录手机号: ${phoneController.text.trim()}');
    debugPrint('登录验证码: ${codeController.text.trim()}');
    request(()async{
      Map<String, dynamic> response = await requestClient.post("/vlogin",data: {"mobile":phoneController.text,"vcode":codeController.text});
      print(response);
      globalController.userModel = UserModel.fromJson(response["user"]);
      globalController.token = response["token"];
      await globalController.saveToken(globalController.token ?? "", globalController.userModel);
      if (globalController.token != null && globalController.token!.isNotEmpty) {
        //需要先判断有没有绑定过包厢，如果没有绑定过包厢，先跳转到绑定包厢页面
         Get.offNamed(AllRoutes.liveFeedPage);
      }
    },onError: (exception){
      SmartDialog.showNotify(msg: exception.message ?? ApiException.unknownException, notifyType: NotifyType.error);
      return true;
    });
  }

  /// 启动 60s 倒计时
  void _startCountdown() {
    countdown.value = _countdownSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value <= 1) {
        countdown.value = 0;
        timer.cancel();
      } else {
        countdown.value--;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    _timer = null;
    phoneController.dispose();
    codeController.dispose();
    super.onClose();
  }
}