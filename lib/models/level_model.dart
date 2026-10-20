import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/generated/json/level_model.g.dart';
import 'dart:convert';
export 'package:peiboshow/generated/json/level_model.g.dart';

@JsonSerializable()
class LevelModel {
	int? id;
	String? name;
	String? value;
	int? intValue;
	String? type;
	int? extValue;

	LevelModel();

	factory LevelModel.fromJson(Map<String, dynamic> json) => $LevelModelFromJson(json);

	Map<String, dynamic> toJson() => $LevelModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}