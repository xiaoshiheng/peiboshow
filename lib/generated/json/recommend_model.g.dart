import 'package:peiboshow/generated/json/base/json_convert_content.dart';
import 'package:peiboshow/models/recommend_model.dart';

RecommendModel $RecommendModelFromJson(Map<String, dynamic> json) {
  final RecommendModel recommendModel = RecommendModel();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    recommendModel.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    recommendModel.name = name;
  }
  final String? lhName = jsonConvert.convert<String>(json['lhName']);
  if (lhName != null) {
    recommendModel.lhName = lhName;
  }
  return recommendModel;
}

Map<String, dynamic> $RecommendModelToJson(RecommendModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['name'] = entity.name;
  data['lhName'] = entity.lhName;
  return data;
}

extension RecommendModelExtension on RecommendModel {
  RecommendModel copyWith({
    int? id,
    String? name,
    String? lhName,
  }) {
    return RecommendModel()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..lhName = lhName ?? this.lhName;
  }
}