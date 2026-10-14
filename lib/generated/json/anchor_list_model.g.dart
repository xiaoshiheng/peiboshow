import 'package:peiboshow/generated/json/base/json_convert_content.dart';
import 'package:peiboshow/models/anchor_list_model.dart';
import 'package:peiboshow/models/anchor_model.dart';


AnchorListModel $AnchorListModelFromJson(Map<String, dynamic> json) {
  final AnchorListModel anchorListModel = AnchorListModel();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    anchorListModel.id = id;
  }
  final int? roomId = jsonConvert.convert<int>(json['roomId']);
  if (roomId != null) {
    anchorListModel.roomId = roomId;
  }
  final int? compayId = jsonConvert.convert<int>(json['compayId']);
  if (compayId != null) {
    anchorListModel.compayId = compayId;
  }
  final int? itemId = jsonConvert.convert<int>(json['itemId']);
  if (itemId != null) {
    anchorListModel.itemId = itemId;
  }
  final int? userId = jsonConvert.convert<int>(json['userId']);
  if (userId != null) {
    anchorListModel.userId = userId;
  }
  final String? roonName = jsonConvert.convert<String>(json['roonName']);
  if (roonName != null) {
    anchorListModel.roonName = roonName;
  }
  final AnchorModel? sitem = jsonConvert.convert<AnchorModel>(json['sitem']);
  if (sitem != null) {
    anchorListModel.sitem = sitem;
  }
  final int? managerId = jsonConvert.convert<int>(json['managerId']);
  if (managerId != null) {
    anchorListModel.managerId = managerId;
  }
  final String? managerName = jsonConvert.convert<String>(json['managerName']);
  if (managerName != null) {
    anchorListModel.managerName = managerName;
  }
  final String? roomName0 = jsonConvert.convert<String>(json['roomName0']);
  if (roomName0 != null) {
    anchorListModel.roomName0 = roomName0;
  }
  return anchorListModel;
}

Map<String, dynamic> $AnchorListModelToJson(AnchorListModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['roomId'] = entity.roomId;
  data['compayId'] = entity.compayId;
  data['itemId'] = entity.itemId;
  data['userId'] = entity.userId;
  data['roonName'] = entity.roonName;
  data['sitem'] = entity.sitem?.toJson();
  data['managerId'] = entity.managerId;
  data['managerName'] = entity.managerName;
  data['roomName0'] = entity.roomName0;
  return data;
}

extension AnchorListModelExtension on AnchorListModel {
  AnchorListModel copyWith({
    int? id,
    int? roomId,
    int? compayId,
    int? itemId,
    int? userId,
    String? roonName,
    AnchorModel? sitem,
    int? managerId,
    String? managerName,
    String? roomName0,
  }) {
    return AnchorListModel()
      ..id = id ?? this.id
      ..roomId = roomId ?? this.roomId
      ..compayId = compayId ?? this.compayId
      ..itemId = itemId ?? this.itemId
      ..userId = userId ?? this.userId
      ..roonName = roonName ?? this.roonName
      ..sitem = sitem ?? this.sitem
      ..managerId = managerId ?? this.managerId
      ..managerName = managerName ?? this.managerName
      ..roomName0 = roomName0 ?? this.roomName0;
  }
}