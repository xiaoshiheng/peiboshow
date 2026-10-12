import 'package:peiboshow/generated/json/base/json_convert_content.dart';
import 'package:peiboshow/models/user_model.dart';

UserModel $UserModelFromJson(Map<String, dynamic> json) {
  final UserModel userModel = UserModel();
  final int? roleId = jsonConvert.convert<int>(json['roleId']);
  if (roleId != null) {
    userModel.roleId = roleId;
  }
  final String? nick = jsonConvert.convert<String>(json['nick']);
  if (nick != null) {
    userModel.nick = nick;
  }
  final String? mobile = jsonConvert.convert<String>(json['mobile']);
  if (mobile != null) {
    userModel.mobile = mobile;
  }
  final String? roleName = jsonConvert.convert<String>(json['roleName']);
  if (roleName != null) {
    userModel.roleName = roleName;
  }
  final String? companyName = jsonConvert.convert<String>(json['companyName']);
  if (companyName != null) {
    userModel.companyName = companyName;
  }
  final int? companyId = jsonConvert.convert<int>(json['companyId']);
  if (companyId != null) {
    userModel.companyId = companyId;
  }
  final int? sex = jsonConvert.convert<int>(json['sex']);
  if (sex != null) {
    userModel.sex = sex;
  }
  return userModel;
}

Map<String, dynamic> $UserModelToJson(UserModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['roleId'] = entity.roleId;
  data['nick'] = entity.nick;
  data['mobile'] = entity.mobile;
  data['roleName'] = entity.roleName;
  data['companyName'] = entity.companyName;
  data['companyId'] = entity.companyId;
  data['sex'] = entity.sex;
  return data;
}

extension UserModelExtension on UserModel {
  UserModel copyWith({
    int? roleId,
    String? nick,
    String? mobile,
    String? roleName,
    String? companyName,
    int? companyId,
    int? sex,
  }) {
    return UserModel()
      ..roleId = roleId ?? this.roleId
      ..nick = nick ?? this.nick
      ..mobile = mobile ?? this.mobile
      ..roleName = roleName ?? this.roleName
      ..companyName = companyName ?? this.companyName
      ..companyId = companyId ?? this.companyId
      ..sex = sex ?? this.sex;
  }
}