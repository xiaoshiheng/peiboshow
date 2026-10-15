import 'dart:convert';

import 'add_anchor_model.dart';

/// AddAnchorModel 的展示层扩展(单独文件,插件重新生成 model 不会丢失)
extension AddAnchorModelExt on AddAnchorModel {
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
}