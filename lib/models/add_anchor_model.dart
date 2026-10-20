import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/generated/json/add_anchor_model.g.dart';
import 'dart:convert';
export 'package:peiboshow/generated/json/add_anchor_model.g.dart';

@JsonSerializable()
class AddAnchorModel {
	int? id;
	String? name;
	int? companyId;
	String? status;
	String? process;
	String? level;
	String? picUrl;
	int? userNo;
	String? statusCN;
	String? processCN;
	String? levelCN;

	AddAnchorModel();

	factory AddAnchorModel.fromJson(Map<String, dynamic> json) => $AddAnchorModelFromJson(json);

	Map<String, dynamic> toJson() => $AddAnchorModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}