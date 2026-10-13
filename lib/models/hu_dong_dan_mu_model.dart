import 'package:peiboshow/generated/json/base/json_field.dart';
import 'package:peiboshow/generated/json/hu_dong_dan_mu_model.g.dart';
import 'dart:convert';
export 'package:peiboshow/generated/json/hu_dong_dan_mu_model.g.dart';

@JsonSerializable()
class HuDongDanMuModel {
	int? msgType;
	int? companyId;
	int? customerId;
	String? customerName;
	int? itemId;
	int? userNo;
	int? productId;
	int? productType;
	int? payAmount;
	int? zhiboRoomId;
	String? createTime;
	String? presentName;
	String? presentLogo;
	String? comment;

	HuDongDanMuModel();

	factory HuDongDanMuModel.fromJson(Map<String, dynamic> json) => $HuDongDanMuModelFromJson(json);

	Map<String, dynamic> toJson() => $HuDongDanMuModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}