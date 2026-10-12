import 'package:dio/dio.dart';

import '../models/api_response/api_response.dart';
import '../models/api_response/raw_data.dart';
import 'api_configs.dart';
import 'api_exception.dart';
import 'api_token_interceptor.dart';

RequestClient requestClient = RequestClient();
class RequestClient{
  late Dio _dio;
  RequestClient() {
    _dio = Dio(
        BaseOptions(
          //baseUrl: RequestConfig.baseUrl,
            connectTimeout:Duration(milliseconds: RequestConfig.connectTimeout),
            headers: {"Content-Type":"application/json"}
        )
    );
    //添加token拦截器
    _dio.interceptors.add(TokenInterceptor());
    //添加请求信息拦截器
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

  }
  Future<T?> request<T>(
      String url, {
        String method = "Get",
        Map<String, dynamic>? queryParameters,
        data,
        Map<String, dynamic>? headers,
        Function(ApiResponse<T>)? onResponse,
        bool Function(ApiException)? onError,
      }) async {
    try {
      Options options = Options()
        ..method = method
        ..headers = headers;


      //data = _convertRequestData(data);

      Response response = await _dio.request(url,
          queryParameters: queryParameters, data: data, options: options);

      return _handleResponse<T>(response, onResponse);
    } catch (e) {
      var exception = ApiException.from(e);
      //特殊的call方法。如果传入的回调方法返回的值是true，则不抛出错误
      if(onError?.call(exception) != true){
        throw exception;
      }
    }

    return null;
  }

  Future<T?> get<T>(
      String url, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        bool showLoading = true,
        Function(ApiResponse<T>)? onResponse,
        bool Function(ApiException)? onError,
      }) {
    return request(url,
        queryParameters: queryParameters,
        headers: headers,
        onResponse: onResponse,
        onError: onError);
  }

  Future<T?> post<T>(
      String url, {
        Map<String, dynamic>? queryParameters,
        data,
        Map<String, dynamic>? headers,
        bool showLoading = true,
        Function(ApiResponse<T>)? onResponse,
        bool Function(ApiException)? onError,
      }) {
    return request(url,
        method: "POST",
        queryParameters: queryParameters,
        data: data,
        headers: headers ?? {},
        onResponse: onResponse,
        onError: onError);
  }

  Future<T?> delete<T>(
      String url, {
        Map<String, dynamic>? queryParameters,
        data,
        Map<String, dynamic>? headers,
        bool showLoading = true,
        Function(ApiResponse<T>)? onResponse,
        bool Function(ApiException)? onError,
      }) {
    return request(url,
        method: "DELETE",
        queryParameters: queryParameters,
        data: data,
        headers: headers,
        onResponse: onResponse,
        onError: onError);
  }

  Future<T?> put<T>(
      String url, {
        Map<String, dynamic>? queryParameters,
        data,
        Map<String, dynamic>? headers,
        bool showLoading = true,
        Function(ApiResponse<T>)? onResponse,
        bool Function(ApiException)? onError,
      }) {
    return request(url,
        method: "PUT",
        queryParameters: queryParameters,
        data: data,
        headers: headers,
        onResponse: onResponse,
        onError: onError);
  }

  ///请求响应内容处理
  T? _handleResponse<T>(Response response, Function(ApiResponse<T>)? onResponse,) {
    if (response.statusCode == 200) {
      if(T.toString() == (RawData).toString()){
        RawData raw = RawData();
        raw.value = response.data;
        return raw as T;
      }else {
        ApiResponse<T> apiResponse = ApiResponse<T>.fromJson(response.data);
        onResponse?.call(apiResponse);
        return _handleBusinessResponse<T>(apiResponse);
      }
    } else {
      var exception = ApiException(response.statusCode, ApiException.unknownException);
      throw exception;
    }
  }

  ///业务内容处理
  T? _handleBusinessResponse<T>(ApiResponse<T> response) {
    if (RequestConfig.successCode.contains(response.code)) {
      return response.data;
    } else {
      var exception = ApiException(response.code, response.message);
      throw exception;
    }
  }
}