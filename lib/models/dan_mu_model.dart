import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/generated/json/dan_mu_model.g.dart';
import 'dart:convert';

import 'package:peiboshow/models/hu_dong_dan_mu_model.dart';
import 'package:peiboshow/models/live_room_dan_mu_model.dart';
export 'package:peiboshow/generated/json/dan_mu_model.g.dart';

@JsonSerializable()
class DanMuModel {
	int? messageType;
	HuDongDanMuModel? hudongMsgVo;
	LiveRoomDanMuModel? zhiboRoomVo;
	String? NewUserName;

	DanMuModel();

	factory DanMuModel.fromJson(Map<String, dynamic> json) => $DanMuModelFromJson(json);

	Map<String, dynamic> toJson() => $DanMuModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}