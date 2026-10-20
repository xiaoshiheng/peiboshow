import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/generated/json/anchor_model.g.dart';
import 'dart:convert';
export 'package:peiboshow/generated/json/anchor_model.g.dart';

@JsonSerializable()
class AnchorModel {
	int? id;
	int? sysUserId;
	String? title;
	int? companyId;
	String? level;
	String? picUrl;
	String? zhiboRoomId;
	int? age;
	int? height;
	String? levelCN;
	

	AnchorModel();

	factory AnchorModel.fromJson(Map<String, dynamic> json) => $AnchorModelFromJson(json);

	Map<String, dynamic> toJson() => $AnchorModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}