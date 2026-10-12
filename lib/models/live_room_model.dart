import 'dart:ffi';

import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/generated/json/live_room_model.g.dart';
import 'dart:convert';
export 'package:peiboshow/generated/json/live_room_model.g.dart';

@JsonSerializable()
class LiveRoomModel {
	int? id;
	int? companyld;
	int? outRoomld;
	String? roomName;
	String? roomSubject;
	String? channelld;
	int? channelType;
	int? zhiboType;
	int? screenType;
	int? size;
	int? status;
	dynamic features;
	String? createTime;
	String? updateTime;
	String? startTime;
	String? endTime;
	int? hostUserld;
	String? pushUrl;
	String? httpPullUrl;//flv
	String? hlsPullUrl;//hls
	String? rtsPullUrl;//rts
	String? rtmpPullUrl;//rtmp
	int? memberCount;
	int? memberTimes;
	int? itemCount;
	int? itemTimes;
	int? zanTimes;
	int? tipTimes;
	int? tipAmount;
	int? onlineMemberCount;
	int? onlineltemCount;
	int? orderCount;
	String? companyName;
	String? channelTypeCN;
	String? statusCN;
	dynamic videoSequenceDto;
	String? picUrl;
	dynamic itemOnline;
	int? isFull;
	int? zhiboNumStart;
	int? zhiboNumEnd;


	LiveRoomModel();

	factory LiveRoomModel.fromJson(Map<String, dynamic> json) => $LiveRoomModelFromJson(json);

	Map<String, dynamic> toJson() => $LiveRoomModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}