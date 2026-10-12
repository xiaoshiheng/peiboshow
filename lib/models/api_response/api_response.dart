import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/models/api_response/api_response.g.dart';
import 'dart:convert';
export 'package:peiboshow/models/api_response/api_response.g.dart';

class ApiResponse<T> {
	int? code;
	String? message;
	T? data;

	ApiResponse();

	factory ApiResponse.fromJson(Map<String, dynamic> json) => $ApiResponseFromJson<T>(json);

	Map<String, dynamic> toJson() => $ApiResponseToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}