import 'dart:convert';

import 'anchor_model.dart';
import 'anchor_list_model.dart';

/// AnchorModel 的展示层扩展(单独文件,插件重新生成 model 不会丢失)
extension AnchorModelExt on AnchorModel {
  /// picUrl 是 JSON 字符串数组,解析出所有 fileUrl
  List<String> get picUrls {
    if (picUrl == null || picUrl!.isEmpty) return const [];
    try {
      final decoded = jsonDecode(picUrl!);
      if (decoded is List) {
        return decoded
            .map((e) => (e is Map ? e['fileUrl'] : null)?.toString())
            .whereType<String>()
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  /// 头像: picUrl 第一条数据的 fileUrl
  String get avatarUrl {
    final urls = picUrls;
    return urls.isEmpty ? '' : urls.first;
  }

  /// 等级徽标文案(如有更多等级映射在此补充)
  String get levelText => _levelNames[level] ?? level ?? '';
  static const Map<String, String> _levelNames = {
    'five_level': '永恒钻石',
  };

  /// 昵称下方副标题(年龄/身高)
  String get subText {
    final parts = <String>[
      if (age != null) '${age}岁',
      if (height != null) '${height}cm',
    ];
    return parts.join('  ');
  }
}

/// AnchorListModel 的展示层扩展(单独文件,插件重新生成 model 不会丢失)
extension AnchorListModelExt on AnchorListModel {
  /// 下单时间格式化为 HH:mm
  String get orderTimeHM {
    final String? t = preOrderTime;
    if (t == null || t.isEmpty) return '';
    final DateTime? parsed = DateTime.tryParse(t);
    if (parsed == null) return t;
    return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
  }
}
