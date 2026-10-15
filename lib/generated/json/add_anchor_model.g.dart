import 'package:peiboshow/generated/json/base/json_convert_content.dart';
import 'package:peiboshow/models/add_anchor_model.dart';

AddAnchorModel $AddAnchorModelFromJson(Map<String, dynamic> json) {
  final AddAnchorModel addAnchorModel = AddAnchorModel();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    addAnchorModel.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    addAnchorModel.name = name;
  }
  final int? companyId = jsonConvert.convert<int>(json['companyId']);
  if (companyId != null) {
    addAnchorModel.companyId = companyId;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    addAnchorModel.status = status;
  }
  final String? process = jsonConvert.convert<String>(json['process']);
  if (process != null) {
    addAnchorModel.process = process;
  }
  final String? level = jsonConvert.convert<String>(json['level']);
  if (level != null) {
    addAnchorModel.level = level;
  }
  final String? picUrl = jsonConvert.convert<String>(json['picUrl']);
  if (picUrl != null) {
    addAnchorModel.picUrl = picUrl;
  }
  final int? userNo = jsonConvert.convert<int>(json['userNo']);
  if (userNo != null) {
    addAnchorModel.userNo = userNo;
  }
  final String? statusCN = jsonConvert.convert<String>(json['statusCN']);
  if (statusCN != null) {
    addAnchorModel.statusCN = statusCN;
  }
  final String? processCN = jsonConvert.convert<String>(json['processCN']);
  if (processCN != null) {
    addAnchorModel.processCN = processCN;
  }
  return addAnchorModel;
}

Map<String, dynamic> $AddAnchorModelToJson(AddAnchorModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['name'] = entity.name;
  data['companyId'] = entity.companyId;
  data['status'] = entity.status;
  data['process'] = entity.process;
  data['level'] = entity.level;
  data['picUrl'] = entity.picUrl;
  data['userNo'] = entity.userNo;
  data['statusCN'] = entity.statusCN;
  data['processCN'] = entity.processCN;
  return data;
}

extension AddAnchorModelExtension on AddAnchorModel {
  AddAnchorModel copyWith({
    int? id,
    String? name,
    int? companyId,
    String? status,
    String? process,
    String? level,
    String? picUrl,
    int? userNo,
    String? statusCN,
    String? processCN,
  }) {
    return AddAnchorModel()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..companyId = companyId ?? this.companyId
      ..status = status ?? this.status
      ..process = process ?? this.process
      ..level = level ?? this.level
      ..picUrl = picUrl ?? this.picUrl
      ..userNo = userNo ?? this.userNo
      ..statusCN = statusCN ?? this.statusCN
      ..processCN = processCN ?? this.processCN;
  }
}