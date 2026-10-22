import 'confirmed_anchor_model.dart';

/// ConfirmedAnchorModel 的展示层扩展(单独文件,插件重新生成 model 不会丢失)
extension ConfirmedAnchorModelExt on ConfirmedAnchorModel {
  /// 预约时间(preOrderTime)格式化为 HH:mm
  String get preOrderTimeHM {
    final String? t = preOrderTime;
    if (t == null || t.isEmpty) return '';
    final DateTime? parsed = DateTime.tryParse(t);
    if (parsed == null) return t;
    return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
  }
}