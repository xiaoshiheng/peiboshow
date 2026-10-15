import 'package:peiboshow/generated/json/base/json_convert_content.dart';
import 'package:peiboshow/models/dan_mu_model.dart';
import 'package:peiboshow/models/hu_dong_dan_mu_model.dart';

import 'package:peiboshow/models/live_room_dan_mu_model.dart';


DanMuModel $DanMuModelFromJson(Map<String, dynamic> json) {
  final DanMuModel danMuModel = DanMuModel();
  final int? messageType = jsonConvert.convert<int>(json['messageType']);
  if (messageType != null) {
    danMuModel.messageType = messageType;
  }
  final HuDongDanMuModel? hudongMsgVo = jsonConvert.convert<HuDongDanMuModel>(
      json['hudongMsgVo']);
  if (hudongMsgVo != null) {
    danMuModel.hudongMsgVo = hudongMsgVo;
  }
  final LiveRoomDanMuModel? zhiboRoomVo = jsonConvert.convert<
      LiveRoomDanMuModel>(json['zhiboRoomVo']);
  if (zhiboRoomVo != null) {
    danMuModel.zhiboRoomVo = zhiboRoomVo;
  }
  final String? newUserName = jsonConvert.convert<String>(json['newUserName']);
  if (newUserName != null) {
    danMuModel.newUserName = newUserName;
  }
  final String? content = jsonConvert.convert<String>(json['content']);
  if (content != null) {
    danMuModel.content = content;
  }
  final int? bizType = jsonConvert.convert<int>(json['bizType']);
  if (bizType != null) {
    danMuModel.bizType = bizType;
  }
  return danMuModel;
}

Map<String, dynamic> $DanMuModelToJson(DanMuModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['messageType'] = entity.messageType;
  data['hudongMsgVo'] = entity.hudongMsgVo?.toJson();
  data['zhiboRoomVo'] = entity.zhiboRoomVo?.toJson();
  data['newUserName'] = entity.newUserName;
  data['content'] = entity.content;
  data['bizType'] = entity.bizType;
  return data;
}

extension DanMuModelExtension on DanMuModel {
  DanMuModel copyWith({
    int? messageType,
    HuDongDanMuModel? hudongMsgVo,
    LiveRoomDanMuModel? zhiboRoomVo,
    String? newUserName,
    String? content,
    int? bizType,
  }) {
    return DanMuModel()
      ..messageType = messageType ?? this.messageType
      ..hudongMsgVo = hudongMsgVo ?? this.hudongMsgVo
      ..zhiboRoomVo = zhiboRoomVo ?? this.zhiboRoomVo
      ..newUserName = newUserName ?? this.newUserName
      ..content = content ?? this.content
      ..bizType = bizType ?? this.bizType;
  }
}