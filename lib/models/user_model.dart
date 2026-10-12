import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/generated/json/user_model.g.dart';
import 'dart:convert';
export 'package:peiboshow/generated/json/user_model.g.dart';

@JsonSerializable()
class UserModel {
	int? roleId;
	String? nick;
	String? mobile;
	String? roleName;
	String? companyName;
	int? companyId;
	int? sex;

	UserModel();

	factory UserModel.fromJson(Map<String, dynamic> json) => $UserModelFromJson(json);

	Map<String, dynamic> toJson() => $UserModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}