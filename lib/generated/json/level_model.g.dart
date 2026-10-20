import 'package:peiboshow/generated/json/base/json_convert_content.dart';
import 'package:peiboshow/models/level_model.dart';

LevelModel $LevelModelFromJson(Map<String, dynamic> json) {
  final LevelModel levelModel = LevelModel();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    levelModel.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    levelModel.name = name;
  }
  final String? value = jsonConvert.convert<String>(json['value']);
  if (value != null) {
    levelModel.value = value;
  }
  final int? intValue = jsonConvert.convert<int>(json['intValue']);
  if (intValue != null) {
    levelModel.intValue = intValue;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    levelModel.type = type;
  }
  final int? extValue = jsonConvert.convert<int>(json['extValue']);
  if (extValue != null) {
    levelModel.extValue = extValue;
  }
  return levelModel;
}

Map<String, dynamic> $LevelModelToJson(LevelModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['name'] = entity.name;
  data['value'] = entity.value;
  data['intValue'] = entity.intValue;
  data['type'] = entity.type;
  data['extValue'] = entity.extValue;
  return data;
}

extension LevelModelExtension on LevelModel {
  LevelModel copyWith({
    int? id,
    String? name,
    String? value,
    int? intValue,
    String? type,
    int? extValue,
  }) {
    return LevelModel()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..value = value ?? this.value
      ..intValue = intValue ?? this.intValue
      ..type = type ?? this.type
      ..extValue = extValue ?? this.extValue;
  }
}