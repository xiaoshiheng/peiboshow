import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37373A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Icon
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'images/app_icon.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '欢迎来到 PeiboShow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildPhoneField(),
                const SizedBox(height: 16),
                _buildCodeField(),
                const SizedBox(height: 32),
                _buildLoginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 手机号输入框
  Widget _buildPhoneField() {
    return TextField(
      controller: controller.phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 11,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(
        hintText: '请输入手机号',
        icon: Icons.phone_android,
      ).copyWith(counterText: ''),
    );
  }

  /// 验证码输入框
  Widget _buildCodeField() {
    return TextField(
      controller: controller.codeController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: Colors.white),
      onSubmitted: (_) => _handleLogin(),
      decoration: _inputDecoration(
        hintText: '请输入验证码',
        icon: Icons.sms_outlined,
      ).copyWith(
        counterText: '',
        suffixIcon: _buildSendCodeButton(),
      ),
    );
  }

  /// 获取验证码按钮(含 60s 倒计时)
  Widget _buildSendCodeButton() {
    return Obx(() {
      final counting = controller.isCountingDown;
      final sending = controller.isSendingCode.value;
      final enabled = !counting && !sending;

      final String text;
      if (counting) {
        text = '${controller.countdown.value}s后重发';
      } else if (sending) {
        text = '发送中...';
      } else {
        text = '获取验证码';
      }

      return TextButton(
        onPressed: enabled ? _handleSendCode : null,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: enabled ? Colors.red : Colors.white38,
          ),
        ),
      );
    });
  }

  /// 登录按钮
  Widget _buildLoginButton(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isLoading.value ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.red.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '登录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// 统一的输入框样式
  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  /// 处理获取验证码点击
  Future<void> _handleSendCode() async {
    final error = controller.validatePhone();
    if (error != null) {
      _showMessage(error);
      return;
    }
    await controller.sendCode();
  }

  /// 处理登录点击
  Future<void> _handleLogin() async {
    final error = controller.validate();
    if (error != null) {
      _showMessage(error);
      return;
    }

    controller.isLoading.value = true;
    try {
      await controller.login();
    } finally {
      controller.isLoading.value = false;
    }
  }

  void _showMessage(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }
}
