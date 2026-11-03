import 'package:peiboshow/generated/json/base/json_convert_content.dart';
import 'package:peiboshow/models/confirmed_anchor_model.dart';

ConfirmedAnchorModel $ConfirmedAnchorModelFromJson(Map<String, dynamic> json) {
  final ConfirmedAnchorModel confirmedAnchorModel = ConfirmedAnchorModel();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    confirmedAnchorModel.id = id;
  }
  final String? createTime = jsonConvert.convert<String>(json['createTime']);
  if (createTime != null) {
    confirmedAnchorModel.createTime = createTime;
  }
  final int? roomId = jsonConvert.convert<int>(json['roomId']);
  if (roomId != null) {
    confirmedAnchorModel.roomId = roomId;
  }
  final int? companyId = jsonConvert.convert<int>(json['companyId']);
  if (companyId != null) {
    confirmedAnchorModel.companyId = companyId;
  }
  final int? itemId = jsonConvert.convert<int>(json['itemId']);
  if (itemId != null) {
    confirmedAnchorModel.itemId = itemId;
  }
  final String? managerName = jsonConvert.convert<String>(json['managerName']);
  if (managerName != null) {
    confirmedAnchorModel.managerName = managerName;
  }
  final String? roomName0 = jsonConvert.convert<String>(json['roomName0']);
  if (roomName0 != null) {
    confirmedAnchorModel.roomName0 = roomName0;
  }
  final String? preOrderTime = jsonConvert.convert<String>(
      json['preOrderTime']);
  if (preOrderTime != null) {
    confirmedAnchorModel.preOrderTime = preOrderTime;
  }
  final String? roomName = jsonConvert.convert<String>(json['roomName']);
  if (roomName != null) {
    confirmedAnchorModel.roomName = roomName;
  }
  final String? itemName = jsonConvert.convert<String>(json['itemName']);
  if (itemName != null) {
    confirmedAnchorModel.itemName = itemName;
  }
  final int? arriveFlag = jsonConvert.convert<int>(json['arriveFlag']);
  if (arriveFlag != null) {
    confirmedAnchorModel.arriveFlag = arriveFlag;
  }
  return confirmedAnchorModel;
}

Map<String, dynamic> $ConfirmedAnchorModelToJson(ConfirmedAnchorModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['createTime'] = entity.createTime;
  data['roomId'] = entity.roomId;
  data['companyId'] = entity.companyId;
  data['itemId'] = entity.itemId;
  data['managerName'] = entity.managerName;
  data['roomName0'] = entity.roomName0;
  data['preOrderTime'] = entity.preOrderTime;
  data['roomName'] = entity.roomName;
  data['itemName'] = entity.itemName;
  data['arriveFlag'] = entity.arriveFlag;
  return data;
}

extension ConfirmedAnchorModelExtension on ConfirmedAnchorModel {
  ConfirmedAnchorModel copyWith({
    int? id,
    String? createTime,
    int? roomId,
    int? companyId,
    int? itemId,
    String? managerName,
    String? roomName0,
    String? preOrderTime,
    String? roomName,
    String? itemName,
    int? arriveFlag,
  }) {
    return ConfirmedAnchorModel()
      ..id = id ?? this.id
      ..createTime = createTime ?? this.createTime
      ..roomId = roomId ?? this.roomId
      ..companyId = companyId ?? this.companyId
      ..itemId = itemId ?? this.itemId
      ..managerName = managerName ?? this.managerName
      ..roomName0 = roomName0 ?? this.roomName0
      ..preOrderTime = preOrderTime ?? this.preOrderTime
      ..roomName = roomName ?? this.roomName
      ..itemName = itemName ?? this.itemName
      ..arriveFlag = arriveFlag ?? this.arriveFlag;
  }
}