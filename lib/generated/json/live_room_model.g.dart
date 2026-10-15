import 'package:peiboshow/generated/json/base/json_convert_content.dart';
import 'package:peiboshow/models/live_room_model.dart';
import 'dart:ffi';


LiveRoomModel $LiveRoomModelFromJson(Map<String, dynamic> json) {
  final LiveRoomModel liveRoomModel = LiveRoomModel();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    liveRoomModel.id = id;
  }
  final int? companyld = jsonConvert.convert<int>(json['companyld']);
  if (companyld != null) {
    liveRoomModel.companyld = companyld;
  }
  final int? outRoomld = jsonConvert.convert<int>(json['outRoomld']);
  if (outRoomld != null) {
    liveRoomModel.outRoomld = outRoomld;
  }
  final String? roomName = jsonConvert.convert<String>(json['roomName']);
  if (roomName != null) {
    liveRoomModel.roomName = roomName;
  }
  final String? roomSubject = jsonConvert.convert<String>(json['roomSubject']);
  if (roomSubject != null) {
    liveRoomModel.roomSubject = roomSubject;
  }
  final String? channelld = jsonConvert.convert<String>(json['channelld']);
  if (channelld != null) {
    liveRoomModel.channelld = channelld;
  }
  final int? channelType = jsonConvert.convert<int>(json['channelType']);
  if (channelType != null) {
    liveRoomModel.channelType = channelType;
  }
  final int? zhiboType = jsonConvert.convert<int>(json['zhiboType']);
  if (zhiboType != null) {
    liveRoomModel.zhiboType = zhiboType;
  }
  final int? screenType = jsonConvert.convert<int>(json['screenType']);
  if (screenType != null) {
    liveRoomModel.screenType = screenType;
  }
  final int? size = jsonConvert.convert<int>(json['size']);
  if (size != null) {
    liveRoomModel.size = size;
  }
  final int? status = jsonConvert.convert<int>(json['status']);
  if (status != null) {
    liveRoomModel.status = status;
  }
  final dynamic features = json['features'];
  if (features != null) {
    liveRoomModel.features = features;
  }
  final String? createTime = jsonConvert.convert<String>(json['createTime']);
  if (createTime != null) {
    liveRoomModel.createTime = createTime;
  }
  final String? updateTime = jsonConvert.convert<String>(json['updateTime']);
  if (updateTime != null) {
    liveRoomModel.updateTime = updateTime;
  }
  final String? startTime = jsonConvert.convert<String>(json['startTime']);
  if (startTime != null) {
    liveRoomModel.startTime = startTime;
  }
  final String? endTime = jsonConvert.convert<String>(json['endTime']);
  if (endTime != null) {
    liveRoomModel.endTime = endTime;
  }
  final int? hostUserld = jsonConvert.convert<int>(json['hostUserld']);
  if (hostUserld != null) {
    liveRoomModel.hostUserld = hostUserld;
  }
  final String? pushUrl = jsonConvert.convert<String>(json['pushUrl']);
  if (pushUrl != null) {
    liveRoomModel.pushUrl = pushUrl;
  }
  final String? httpPullUrl = jsonConvert.convert<String>(json['httpPullUrl']);
  if (httpPullUrl != null) {
    liveRoomModel.httpPullUrl = httpPullUrl;
  }
  final String? hlsPullUrl = jsonConvert.convert<String>(json['hlsPullUrl']);
  if (hlsPullUrl != null) {
    liveRoomModel.hlsPullUrl = hlsPullUrl;
  }
  final String? rtsPullUrl = jsonConvert.convert<String>(json['rtsPullUrl']);
  if (rtsPullUrl != null) {
    liveRoomModel.rtsPullUrl = rtsPullUrl;
  }
  final String? rtmpPullUrl = jsonConvert.convert<String>(json['rtmpPullUrl']);
  if (rtmpPullUrl != null) {
    liveRoomModel.rtmpPullUrl = rtmpPullUrl;
  }
  final int? memberCount = jsonConvert.convert<int>(json['memberCount']);
  if (memberCount != null) {
    liveRoomModel.memberCount = memberCount;
  }
  final int? memberTimes = jsonConvert.convert<int>(json['memberTimes']);
  if (memberTimes != null) {
    liveRoomModel.memberTimes = memberTimes;
  }
  final int? itemCount = jsonConvert.convert<int>(json['itemCount']);
  if (itemCount != null) {
    liveRoomModel.itemCount = itemCount;
  }
  final int? itemTimes = jsonConvert.convert<int>(json['itemTimes']);
  if (itemTimes != null) {
    liveRoomModel.itemTimes = itemTimes;
  }
  final int? zanTimes = jsonConvert.convert<int>(json['zanTimes']);
  if (zanTimes != null) {
    liveRoomModel.zanTimes = zanTimes;
  }
  final int? tipTimes = jsonConvert.convert<int>(json['tipTimes']);
  if (tipTimes != null) {
    liveRoomModel.tipTimes = tipTimes;
  }
  final int? tipAmount = jsonConvert.convert<int>(json['tipAmount']);
  if (tipAmount != null) {
    liveRoomModel.tipAmount = tipAmount;
  }
  final int? onlineMemberCount = jsonConvert.convert<int>(
      json['onlineMemberCount']);
  if (onlineMemberCount != null) {
    liveRoomModel.onlineMemberCount = onlineMemberCount;
  }
  final int? onlineltemCount = jsonConvert.convert<int>(
      json['onlineltemCount']);
  if (onlineltemCount != null) {
    liveRoomModel.onlineltemCount = onlineltemCount;
  }
  final int? orderCount = jsonConvert.convert<int>(json['orderCount']);
  if (orderCount != null) {
    liveRoomModel.orderCount = orderCount;
  }
  final String? companyName = jsonConvert.convert<String>(json['companyName']);
  if (companyName != null) {
    liveRoomModel.companyName = companyName;
  }
  final String? channelTypeCN = jsonConvert.convert<String>(
      json['channelTypeCN']);
  if (channelTypeCN != null) {
    liveRoomModel.channelTypeCN = channelTypeCN;
  }
  final String? statusCN = jsonConvert.convert<String>(json['statusCN']);
  if (statusCN != null) {
    liveRoomModel.statusCN = statusCN;
  }
  final dynamic videoSequenceDto = json['videoSequenceDto'];
  if (videoSequenceDto != null) {
    liveRoomModel.videoSequenceDto = videoSequenceDto;
  }
  final String? picUrl = jsonConvert.convert<String>(json['picUrl']);
  if (picUrl != null) {
    liveRoomModel.picUrl = picUrl;
  }
  final dynamic itemOnline = json['itemOnline'];
  if (itemOnline != null) {
    liveRoomModel.itemOnline = itemOnline;
  }
  final int? isFull = jsonConvert.convert<int>(json['isFull']);
  if (isFull != null) {
    liveRoomModel.isFull = isFull;
  }
  final int? zhiboNumStart = jsonConvert.convert<int>(json['zhiboNumStart']);
  if (zhiboNumStart != null) {
    liveRoomModel.zhiboNumStart = zhiboNumStart;
  }
  final int? zhiboNumEnd = jsonConvert.convert<int>(json['zhiboNumEnd']);
  if (zhiboNumEnd != null) {
    liveRoomModel.zhiboNumEnd = zhiboNumEnd;
  }
  final int? isAdmin = jsonConvert.convert<int>(json['isAdmin']);
  if (isAdmin != null) {
    liveRoomModel.isAdmin = isAdmin;
  }
  return liveRoomModel;
}

Map<String, dynamic> $LiveRoomModelToJson(LiveRoomModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['companyld'] = entity.companyld;
  data['outRoomld'] = entity.outRoomld;
  data['roomName'] = entity.roomName;
  data['roomSubject'] = entity.roomSubject;
  data['channelld'] = entity.channelld;
  data['channelType'] = entity.channelType;
  data['zhiboType'] = entity.zhiboType;
  data['screenType'] = entity.screenType;
  data['size'] = entity.size;
  data['status'] = entity.status;
  data['features'] = entity.features;
  data['createTime'] = entity.createTime;
  data['updateTime'] = entity.updateTime;
  data['startTime'] = entity.startTime;
  data['endTime'] = entity.endTime;
  data['hostUserld'] = entity.hostUserld;
  data['pushUrl'] = entity.pushUrl;
  data['httpPullUrl'] = entity.httpPullUrl;
  data['hlsPullUrl'] = entity.hlsPullUrl;
  data['rtsPullUrl'] = entity.rtsPullUrl;
  data['rtmpPullUrl'] = entity.rtmpPullUrl;
  data['memberCount'] = entity.memberCount;
  data['memberTimes'] = entity.memberTimes;
  data['itemCount'] = entity.itemCount;
  data['itemTimes'] = entity.itemTimes;
  data['zanTimes'] = entity.zanTimes;
  data['tipTimes'] = entity.tipTimes;
  data['tipAmount'] = entity.tipAmount;
  data['onlineMemberCount'] = entity.onlineMemberCount;
  data['onlineltemCount'] = entity.onlineltemCount;
  data['orderCount'] = entity.orderCount;
  data['companyName'] = entity.companyName;
  data['channelTypeCN'] = entity.channelTypeCN;
  data['statusCN'] = entity.statusCN;
  data['videoSequenceDto'] = entity.videoSequenceDto;
  data['picUrl'] = entity.picUrl;
  data['itemOnline'] = entity.itemOnline;
  data['isFull'] = entity.isFull;
  data['zhiboNumStart'] = entity.zhiboNumStart;
  data['zhiboNumEnd'] = entity.zhiboNumEnd;
  data['isAdmin'] = entity.isAdmin;
  return data;
}

extension LiveRoomModelExtension on LiveRoomModel {
  LiveRoomModel copyWith({
    int? id,
    int? companyld,
    int? outRoomld,
    String? roomName,
    String? roomSubject,
    String? channelld,
    int? channelType,
    int? zhiboType,
    int? screenType,
    int? size,
    int? status,
    dynamic features,
    String? createTime,
    String? updateTime,
    String? startTime,
    String? endTime,
    int? hostUserld,
    String? pushUrl,
    String? httpPullUrl,
    String? hlsPullUrl,
    String? rtsPullUrl,
    String? rtmpPullUrl,
    int? memberCount,
    int? memberTimes,
    int? itemCount,
    int? itemTimes,
    int? zanTimes,
    int? tipTimes,
    int? tipAmount,
    int? onlineMemberCount,
    int? onlineltemCount,
    int? orderCount,
    String? companyName,
    String? channelTypeCN,
    String? statusCN,
    dynamic videoSequenceDto,
    String? picUrl,
    dynamic itemOnline,
    int? isFull,
    int? zhiboNumStart,
    int? zhiboNumEnd,
    int? isAdmin,
  }) {
    return LiveRoomModel()
      ..id = id ?? this.id
      ..companyld = companyld ?? this.companyld
      ..outRoomld = outRoomld ?? this.outRoomld
      ..roomName = roomName ?? this.roomName
      ..roomSubject = roomSubject ?? this.roomSubject
      ..channelld = channelld ?? this.channelld
      ..channelType = channelType ?? this.channelType
      ..zhiboType = zhiboType ?? this.zhiboType
      ..screenType = screenType ?? this.screenType
      ..size = size ?? this.size
      ..status = status ?? this.status
      ..features = features ?? this.features
      ..createTime = createTime ?? this.createTime
      ..updateTime = updateTime ?? this.updateTime
      ..startTime = startTime ?? this.startTime
      ..endTime = endTime ?? this.endTime
      ..hostUserld = hostUserld ?? this.hostUserld
      ..pushUrl = pushUrl ?? this.pushUrl
      ..httpPullUrl = httpPullUrl ?? this.httpPullUrl
      ..hlsPullUrl = hlsPullUrl ?? this.hlsPullUrl
      ..rtsPullUrl = rtsPullUrl ?? this.rtsPullUrl
      ..rtmpPullUrl = rtmpPullUrl ?? this.rtmpPullUrl
      ..memberCount = memberCount ?? this.memberCount
      ..memberTimes = memberTimes ?? this.memberTimes
      ..itemCount = itemCount ?? this.itemCount
      ..itemTimes = itemTimes ?? this.itemTimes
      ..zanTimes = zanTimes ?? this.zanTimes
      ..tipTimes = tipTimes ?? this.tipTimes
      ..tipAmount = tipAmount ?? this.tipAmount
      ..onlineMemberCount = onlineMemberCount ?? this.onlineMemberCount
      ..onlineltemCount = onlineltemCount ?? this.onlineltemCount
      ..orderCount = orderCount ?? this.orderCount
      ..companyName = companyName ?? this.companyName
      ..channelTypeCN = channelTypeCN ?? this.channelTypeCN
      ..statusCN = statusCN ?? this.statusCN
      ..videoSequenceDto = videoSequenceDto ?? this.videoSequenceDto
      ..picUrl = picUrl ?? this.picUrl
      ..itemOnline = itemOnline ?? this.itemOnline
      ..isFull = isFull ?? this.isFull
      ..zhiboNumStart = zhiboNumStart ?? this.zhiboNumStart
      ..zhiboNumEnd = zhiboNumEnd ?? this.zhiboNumEnd
      ..isAdmin = isAdmin ?? this.isAdmin;
  }
}