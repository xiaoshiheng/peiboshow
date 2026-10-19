import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/dan_mu_model.dart';
import '../pages/controller/danmu_controller.dart';

/// 直播间弹幕层:房间状态条 + 弹幕列表 + 输入框
class DanmuView extends StatefulWidget {
  /// 对应 DanmuController 的 GetX tag
  final String tag;

  const DanmuView({super.key, required this.tag});

  @override
  State<DanmuView> createState() => _DanmuViewState();
}

class _DanmuViewState extends State<DanmuView> {
  late final DanmuController _controller =
      Get.find<DanmuController>(tag: widget.tag);
  final ScrollController _scrollController = ScrollController();
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    // 新弹幕到达时自动滚到底部
    _worker = ever(_controller.messages, (_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoomStatusBar(),
        Expanded(
          child: Obx(() {
            final list = _controller.messages;
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              itemBuilder: (context, index) => _buildItem(list[index]),
            );
          }),
        ),
      ],
    );
  }

  /// type1: 直播间实时状态(在线人数 / 点赞)
  Widget _buildRoomStatusBar() {
    return Obx(() {
      final info = _controller.roomInfo.value;
      if (info == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            _statusChip(Icons.visibility_outlined,
                '${info.onlineMemberCount ?? 0} 在线'),
            const SizedBox(width: 8),
            _statusChip(Icons.favorite_border, '${info.zanTimes ?? 0}'),
          ],
        ),
      );
    });
  }

  Widget _statusChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  /// 根据 messageType 渲染不同弹幕样式
  Widget _buildItem(DanMuModel danmu) {
    // type3: 游客进入直播间
    if (danmu.messageType == DanMuMessageType.enter) {
      return _systemLine('${danmu.newUserName ?? '游客'} 进入才艺间');
    }

    // type4: 内容消息(bizType 1/2 橙色, 3 红色,字号比其他类型大 3 号)
    if (danmu.messageType == DanMuMessageType.vipEnter) {
      return _contentLine(danmu.content ?? '', danmu.bizType);
    }

    // type2: 互动消息(评论 / 送礼 / 点赞)
    final hudong = danmu.hudongMsgVo;
    final name = hudong?.customerName ?? '用户';
    final comment = hudong?.comment;
    final present = hudong?.presentName;

    if (present != null && present.isNotEmpty) {
      return _richLine(name, ' 送出了 $present', const Color(0xFFFFB74D));
    }
    if (comment != null && comment.isNotEmpty) {
      return _richLine(name, ': $comment', Colors.white);
    }
    return _richLine(name, ' 点了个赞', const Color(0xFFFF8A80));
  }

  /// 内容消息行(type4:bizType 1/2 橙色、3 红色,字号比其他类型大 3 号 -> 14 + 3 = 17)
  Widget _contentLine(String text, int? bizType) {
    // bizType==3(预约谁) 红色;1/2(首次进入看谁/看看谁) 橙色,缺失时默认橙色
    final Color color =
        bizType == 3 ? Colors.red : const Color(0xFFFF9800);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 17,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 3)],
        ),
      ),
    );
  }

  /// 系统提示行(type3 游客进入:弱化的灰色小字提示)
  Widget _systemLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 13,
          fontStyle: FontStyle.italic,
          shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
        ),
      ),
    );
  }

  /// 昵称 + 内容富文本行
  Widget _richLine(String nick, String content, Color contentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, height: 1.3),
          children: [
            TextSpan(
              text: nick,
              style: const TextStyle(
                color: Color(0xFFFFD54F),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: content,
              style: TextStyle(
                color: contentColor,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 3)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}