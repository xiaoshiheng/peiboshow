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
  final TextEditingController _inputController = TextEditingController();
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

  void _onSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _controller.send(text);
    _inputController.clear();
  }

  @override
  void dispose() {
    _worker?.dispose();
    _inputController.dispose();
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
        const SizedBox(height: 8),
        _buildInputBar(),
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
      return _systemLine('${danmu.newUserName ?? '游客'} 进入直播间');
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

  /// 系统提示行(居中弱化样式)
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

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: Colors.white,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _onSend(),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '说点什么...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ),
          ),
          Obx(() {
            final ok = _controller.connected.value;
            return IconButton(
              onPressed: ok ? _onSend : null,
              icon: Icon(
                Icons.send,
                size: 20,
                color: ok ? const Color(0xFFFF4D6D) : Colors.white30,
              ),
            );
          }),
        ],
      ),
    );
  }
}