import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/generated/json/recommend_model.g.dart';
import 'dart:convert';
export 'package:peiboshow/generated/json/recommend_model.g.dart';

@JsonSerializable()
class RecommendModel {
	int? id;
	String? name;
	String? lhName;
	RecommendModel();

	factory RecommendModel.fromJson(Map<String, dynamic> json) => $RecommendModelFromJson(json);

	Map<String, dynamic> toJson() => $RecommendModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}