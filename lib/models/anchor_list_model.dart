import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/generated/json/anchor_list_model.g.dart';
import 'dart:convert';

import 'package:peiboshow/models/anchor_model.dart';
export 'package:peiboshow/generated/json/anchor_list_model.g.dart';

@JsonSerializable()
class AnchorListModel {
	int? id;
	int? roomId;
	int? compayId;
	int? itemId;
	int? userId;
	String? roonName;
	AnchorModel? sitem;
	int? managerId;
	String? managerName;
	String? roomName0;

	AnchorListModel();

	factory AnchorListModel.fromJson(Map<String, dynamic> json) => $AnchorListModelFromJson(json);

	Map<String, dynamic> toJson() => $AnchorListModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}