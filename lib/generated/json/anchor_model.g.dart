import 'package:peiboshow/generated/json/base/json_convert_content.dart';
import 'package:peiboshow/models/anchor_model.dart';

AnchorModel $AnchorModelFromJson(Map<String, dynamic> json) {
  final AnchorModel anchorModel = AnchorModel();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    anchorModel.id = id;
  }
  final int? sysUserId = jsonConvert.convert<int>(json['sysUserId']);
  if (sysUserId != null) {
    anchorModel.sysUserId = sysUserId;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    anchorModel.title = title;
  }
  final int? companyId = jsonConvert.convert<int>(json['companyId']);
  if (companyId != null) {
    anchorModel.companyId = companyId;
  }
  final String? level = jsonConvert.convert<String>(json['level']);
  if (level != null) {
    anchorModel.level = level;
  }
  final String? picUrl = jsonConvert.convert<String>(json['picUrl']);
  if (picUrl != null) {
    anchorModel.picUrl = picUrl;
  }
  final String? zhiboRoomId = jsonConvert.convert<String>(json['zhiboRoomId']);
  if (zhiboRoomId != null) {
    anchorModel.zhiboRoomId = zhiboRoomId;
  }
  final int? age = jsonConvert.convert<int>(json['age']);
  if (age != null) {
    anchorModel.age = age;
  }
  final int? height = jsonConvert.convert<int>(json['height']);
  if (height != null) {
    anchorModel.height = height;
  }
  final int? isLike = jsonConvert.convert<int>(json['isLike']);
  if (isLike != null) {
    anchorModel.isLike = isLike;
  }
  return anchorModel;
}

Map<String, dynamic> $AnchorModelToJson(AnchorModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['sysUserId'] = entity.sysUserId;
  data['title'] = entity.title;
  data['companyId'] = entity.companyId;
  data['level'] = entity.level;
  data['picUrl'] = entity.picUrl;
  data['zhiboRoomId'] = entity.zhiboRoomId;
  data['age'] = entity.age;
  data['height'] = entity.height;
  data['isLike'] = entity.isLike;
  return data;
}

extension AnchorModelExtension on AnchorModel {
  AnchorModel copyWith({
    int? id,
    int? sysUserId,
    String? title,
    int? companyId,
    String? level,
    String? picUrl,
    String? zhiboRoomId,
    int? age,
    int? height,
    int? isLike,
  }) {
    return AnchorModel()
      ..id = id ?? this.id
      ..sysUserId = sysUserId ?? this.sysUserId
      ..title = title ?? this.title
      ..companyId = companyId ?? this.companyId
      ..level = level ?? this.level
      ..picUrl = picUrl ?? this.picUrl
      ..zhiboRoomId = zhiboRoomId ?? this.zhiboRoomId
      ..age = age ?? this.age
      ..height = height ?? this.height
      ..isLike = isLike ?? this.isLike;
  }
}