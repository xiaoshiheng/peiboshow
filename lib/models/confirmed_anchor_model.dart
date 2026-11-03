import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/generated/json/confirmed_anchor_model.g.dart';
import 'dart:convert';
export 'package:peiboshow/generated/json/confirmed_anchor_model.g.dart';

@JsonSerializable()
class ConfirmedAnchorModel {
	int? id;
	String? createTime;
	int? roomId;
	int? companyId;
	int? itemId;
	String? managerName;
	String? roomName0;
	String? preOrderTime;
	String? roomName;
	String? itemName;
	int? arriveFlag;//0,未到场，1已到场

	ConfirmedAnchorModel();

	factory ConfirmedAnchorModel.fromJson(Map<String, dynamic> json) => $ConfirmedAnchorModelFromJson(json);

	Map<String, dynamic> toJson() => $ConfirmedAnchorModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}