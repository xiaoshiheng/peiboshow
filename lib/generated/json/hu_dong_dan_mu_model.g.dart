import 'package:peiboshow/generated/json/base/json_convert_content.dart';
import 'package:peiboshow/models/hu_dong_dan_mu_model.dart';

HuDongDanMuModel $HuDongDanMuModelFromJson(Map<String, dynamic> json) {
  final HuDongDanMuModel huDongDanMuModel = HuDongDanMuModel();
  final int? msgType = jsonConvert.convert<int>(json['msgType']);
  if (msgType != null) {
    huDongDanMuModel.msgType = msgType;
  }
  final int? companyId = jsonConvert.convert<int>(json['companyId']);
  if (companyId != null) {
    huDongDanMuModel.companyId = companyId;
  }
  final int? customerId = jsonConvert.convert<int>(json['customerId']);
  if (customerId != null) {
    huDongDanMuModel.customerId = customerId;
  }
  final String? customerName = jsonConvert.convert<String>(
      json['customerName']);
  if (customerName != null) {
    huDongDanMuModel.customerName = customerName;
  }
  final int? itemId = jsonConvert.convert<int>(json['itemId']);
  if (itemId != null) {
    huDongDanMuModel.itemId = itemId;
  }
  final int? userNo = jsonConvert.convert<int>(json['userNo']);
  if (userNo != null) {
    huDongDanMuModel.userNo = userNo;
  }
  final int? productId = jsonConvert.convert<int>(json['productId']);
  if (productId != null) {
    huDongDanMuModel.productId = productId;
  }
  final int? productType = jsonConvert.convert<int>(json['productType']);
  if (productType != null) {
    huDongDanMuModel.productType = productType;
  }
  final int? payAmount = jsonConvert.convert<int>(json['payAmount']);
  if (payAmount != null) {
    huDongDanMuModel.payAmount = payAmount;
  }
  final int? zhiboRoomId = jsonConvert.convert<int>(json['zhiboRoomId']);
  if (zhiboRoomId != null) {
    huDongDanMuModel.zhiboRoomId = zhiboRoomId;
  }
  final String? createTime = jsonConvert.convert<String>(json['createTime']);
  if (createTime != null) {
    huDongDanMuModel.createTime = createTime;
  }
  final String? presentName = jsonConvert.convert<String>(json['presentName']);
  if (presentName != null) {
    huDongDanMuModel.presentName = presentName;
  }
  final String? presentLogo = jsonConvert.convert<String>(json['presentLogo']);
  if (presentLogo != null) {
    huDongDanMuModel.presentLogo = presentLogo;
  }
  final String? comment = jsonConvert.convert<String>(json['comment']);
  if (comment != null) {
    huDongDanMuModel.comment = comment;
  }
  return huDongDanMuModel;
}

Map<String, dynamic> $HuDongDanMuModelToJson(HuDongDanMuModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['msgType'] = entity.msgType;
  data['companyId'] = entity.companyId;
  data['customerId'] = entity.customerId;
  data['customerName'] = entity.customerName;
  data['itemId'] = entity.itemId;
  data['userNo'] = entity.userNo;
  data['productId'] = entity.productId;
  data['productType'] = entity.productType;
  data['payAmount'] = entity.payAmount;
  data['zhiboRoomId'] = entity.zhiboRoomId;
  data['createTime'] = entity.createTime;
  data['presentName'] = entity.presentName;
  data['presentLogo'] = entity.presentLogo;
  data['comment'] = entity.comment;
  return data;
}

extension HuDongDanMuModelExtension on HuDongDanMuModel {
  HuDongDanMuModel copyWith({
    int? msgType,
    int? companyId,
    int? customerId,
    String? customerName,
    int? itemId,
    int? userNo,
    int? productId,
    int? productType,
    int? payAmount,
    int? zhiboRoomId,
    String? createTime,
    String? presentName,
    String? presentLogo,
    String? comment,
  }) {
    return HuDongDanMuModel()
      ..msgType = msgType ?? this.msgType
      ..companyId = companyId ?? this.companyId
      ..customerId = customerId ?? this.customerId
      ..customerName = customerName ?? this.customerName
      ..itemId = itemId ?? this.itemId
      ..userNo = userNo ?? this.userNo
      ..productId = productId ?? this.productId
      ..productType = productType ?? this.productType
      ..payAmount = payAmount ?? this.payAmount
      ..zhiboRoomId = zhiboRoomId ?? this.zhiboRoomId
      ..createTime = createTime ?? this.createTime
      ..presentName = presentName ?? this.presentName
      ..presentLogo = presentLogo ?? this.presentLogo
      ..comment = comment ?? this.comment;
  }
}