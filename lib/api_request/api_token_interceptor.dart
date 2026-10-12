import 'package:dio/dio.dart';

import '../utils/nsuserdefault.dart';

class TokenInterceptor extends Interceptor{
  late String? token;
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    await getToken(options);
    await getBaseUrl(options);
    super.onRequest(options, handler);
  }

  Future<void> getToken(RequestOptions options) async {
    NSUserDefault userDefault = await NSUserDefault.getInstance();
    token = userDefault.getValueForKey("token");
    options.headers["token"] = token;
  }

  Future<void> getBaseUrl(RequestOptions options) async {
    NSUserDefault userDefault = await NSUserDefault.getInstance();
    String? baseUrl = userDefault.getValueForKey("baseurl");
    options.baseUrl = baseUrl != null ? "http://" + baseUrl : "https://api.chaopaiclub.cn";
  }

}