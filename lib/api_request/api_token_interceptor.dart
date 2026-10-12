import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../utils/nsuserdefault.dart';

class TokenInterceptor extends Interceptor {
  String? token;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final NSUserDefault userDefault = await NSUserDefault.getInstance();
      token = userDefault.getValueForKey("token");
      options.headers["token"] = token;

      final String? baseUrl = userDefault.getValueForKey("baseurl");
      options.baseUrl =
          baseUrl != null ? "http://$baseUrl" : "https://api.chaopaiclub.cn";
    } catch (e) {
      // 即使读取 token / baseUrl 失败，也要放行，避免请求链卡死
      debugPrint('TokenInterceptor error: $e');
    }
    // 保证一定会调用 next，请求才能继续走到 LogInterceptor 并真正发出
    handler.next(options);
  }
}