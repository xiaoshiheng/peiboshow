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
  }) {
    return AnchorListModel()
      ..id = id ?? this.id
      ..roomId = roomId ?? this.roomId
      ..compayId = compayId ?? this.compayId
      ..itemId = itemId ?? this.itemId
      ..userId = userId ?? this.userId
      ..roonName = roonName ?? this.roonName
      ..sitem = sitem ?? this.sitem;
  }
}