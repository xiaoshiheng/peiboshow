import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/generated/json/live_room_dan_mu_model.g.dart';
import 'dart:convert';
export 'package:peiboshow/generated/json/live_room_dan_mu_model.g.dart';

@JsonSerializable()
class LiveRoomDanMuModel {
	int? id;
	int? companyId;
	String? roomName;
	String? roomSubject;
	int? zhiboType;
	int? size;
	int? status;
	int? memberCount;
	int? memberTimes;
	int? itemCount;
	int? itemTimes;
	int? zanTimes;
	int? tipTimes;
	int? tipAmount;
	int? onlineMemberCount;
	int? onlineItemCount;

	LiveRoomDanMuModel();

	factory LiveRoomDanMuModel.fromJson(Map<String, dynamic> json) => $LiveRoomDanMuModelFromJson(json);

	Map<String, dynamic> toJson() => $LiveRoomDanMuModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}