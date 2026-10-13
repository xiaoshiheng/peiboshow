import 'package:peiboshow/generated/json/base/json_convert_content.dart';
import 'package:peiboshow/models/live_room_dan_mu_model.dart';

LiveRoomDanMuModel $LiveRoomDanMuModelFromJson(Map<String, dynamic> json) {
  final LiveRoomDanMuModel liveRoomDanMuModel = LiveRoomDanMuModel();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    liveRoomDanMuModel.id = id;
  }
  final int? companyId = jsonConvert.convert<int>(json['companyId']);
  if (companyId != null) {
    liveRoomDanMuModel.companyId = companyId;
  }
  final String? roomName = jsonConvert.convert<String>(json['roomName']);
  if (roomName != null) {
    liveRoomDanMuModel.roomName = roomName;
  }
  final String? roomSubject = jsonConvert.convert<String>(json['roomSubject']);
  if (roomSubject != null) {
    liveRoomDanMuModel.roomSubject = roomSubject;
  }
  final int? zhiboType = jsonConvert.convert<int>(json['zhiboType']);
  if (zhiboType != null) {
    liveRoomDanMuModel.zhiboType = zhiboType;
  }
  final int? size = jsonConvert.convert<int>(json['size']);
  if (size != null) {
    liveRoomDanMuModel.size = size;
  }
  final int? status = jsonConvert.convert<int>(json['status']);
  if (status != null) {
    liveRoomDanMuModel.status = status;
  }
  final int? memberCount = jsonConvert.convert<int>(json['memberCount']);
  if (memberCount != null) {
    liveRoomDanMuModel.memberCount = memberCount;
  }
  final int? memberTimes = jsonConvert.convert<int>(json['memberTimes']);
  if (memberTimes != null) {
    liveRoomDanMuModel.memberTimes = memberTimes;
  }
  final int? itemCount = jsonConvert.convert<int>(json['itemCount']);
  if (itemCount != null) {
    liveRoomDanMuModel.itemCount = itemCount;
  }
  final int? itemTimes = jsonConvert.convert<int>(json['itemTimes']);
  if (itemTimes != null) {
    liveRoomDanMuModel.itemTimes = itemTimes;
  }
  final int? zanTimes = jsonConvert.convert<int>(json['zanTimes']);
  if (zanTimes != null) {
    liveRoomDanMuModel.zanTimes = zanTimes;
  }
  final int? tipTimes = jsonConvert.convert<int>(json['tipTimes']);
  if (tipTimes != null) {
    liveRoomDanMuModel.tipTimes = tipTimes;
  }
  final int? tipAmount = jsonConvert.convert<int>(json['tipAmount']);
  if (tipAmount != null) {
    liveRoomDanMuModel.tipAmount = tipAmount;
  }
  final int? onlineMemberCount = jsonConvert.convert<int>(
      json['onlineMemberCount']);
  if (onlineMemberCount != null) {
    liveRoomDanMuModel.onlineMemberCount = onlineMemberCount;
  }
  final int? onlineItemCount = jsonConvert.convert<int>(
      json['onlineItemCount']);
  if (onlineItemCount != null) {
    liveRoomDanMuModel.onlineItemCount = onlineItemCount;
  }
  return liveRoomDanMuModel;
}

Map<String, dynamic> $LiveRoomDanMuModelToJson(LiveRoomDanMuModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['companyId'] = entity.companyId;
  data['roomName'] = entity.roomName;
  data['roomSubject'] = entity.roomSubject;
  data['zhiboType'] = entity.zhiboType;
  data['size'] = entity.size;
  data['status'] = entity.status;
  data['memberCount'] = entity.memberCount;
  data['memberTimes'] = entity.memberTimes;
  data['itemCount'] = entity.itemCount;
  data['itemTimes'] = entity.itemTimes;
  data['zanTimes'] = entity.zanTimes;
  data['tipTimes'] = entity.tipTimes;
  data['tipAmount'] = entity.tipAmount;
  data['onlineMemberCount'] = entity.onlineMemberCount;
  data['onlineItemCount'] = entity.onlineItemCount;
  return data;
}

extension LiveRoomDanMuModelExtension on LiveRoomDanMuModel {
  LiveRoomDanMuModel copyWith({
    int? id,
    int? companyId,
    String? roomName,
    String? roomSubject,
    int? zhiboType,
    int? size,
    int? status,
    int? memberCount,
    int? memberTimes,
    int? itemCount,
    int? itemTimes,
    int? zanTimes,
    int? tipTimes,
    int? tipAmount,
    int? onlineMemberCount,
    int? onlineItemCount,
  }) {
    return LiveRoomDanMuModel()
      ..id = id ?? this.id
      ..companyId = companyId ?? this.companyId
      ..roomName = roomName ?? this.roomName
      ..roomSubject = roomSubject ?? this.roomSubject
      ..zhiboType = zhiboType ?? this.zhiboType
      ..size = size ?? this.size
      ..status = status ?? this.status
      ..memberCount = memberCount ?? this.memberCount
      ..memberTimes = memberTimes ?? this.memberTimes
      ..itemCount = itemCount ?? this.itemCount
      ..itemTimes = itemTimes ?? this.itemTimes
      ..zanTimes = zanTimes ?? this.zanTimes
      ..tipTimes = tipTimes ?? this.tipTimes
      ..tipAmount = tipAmount ?? this.tipAmount
      ..onlineMemberCount = onlineMemberCount ?? this.onlineMemberCount
      ..onlineItemCount = onlineItemCount ?? this.onlineItemCount;
  }
}