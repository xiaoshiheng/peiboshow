import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../models/anchor_list_model.dart';
import '../models/anchor_model.dart';
import '../models/anchor_model_ext.dart';
import 'anchor_image_viewer.dart';
import 'controller/anchor_list_controller.dart';

/// 主播列表路由:从右侧划入
class AnchorListRoute extends PopupRoute<void> {
  AnchorListRoute({required this.roomId});

  final int roomId;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'anchor_list';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) =>
      AnchorListPanel(roomId: roomId);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
    );
  }
}

/// 半屏主播列表面板
class AnchorListPanel extends StatefulWidget {
  final int roomId;

  const AnchorListPanel({super.key, required this.roomId});

  @override
  State<AnchorListPanel> createState() => _AnchorListPanelState();
}

class _AnchorListPanelState extends State<AnchorListPanel> {
  String get _tag => 'anchor_list_${widget.roomId}';

  /// 每次打开面板新建控制器(onInit 即请求),关闭时销毁
  late final AnchorListController _controller =
  Get.put(AnchorListController(roomId: widget.roomId), tag: _tag);

  @override
  void dispose() {
    Get.delete<AnchorListController>(tag: _tag);
    super.dispose();
  }

  /// 移出直播间
  Future<void> _onRemove(AnchorListModel item) async {
    final name = item.sitem?.title ?? '该主播';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2C),
        title: const Text('提示',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text('确定将 $name 移出直播间吗?',
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确定',
                  style: TextStyle(color: Color(0xFFFF4D6D)))),
        ],
      ),
    );
    if (confirm != true) return;

    final ok = await _controller.removeAnchor(item);
    if (ok) {
      SmartDialog.showToast('已移出直播间');
      _controller.getAnchorList();
    } else {
      SmartDialog.showToast('移出直播间接口待接入');
    }
  }

  void _openViewer(AnchorModel anchor) {
    final urls = anchor.picUrls;
    if (urls.isEmpty) return;
    AnchorImageViewer.show(context, urls);
  }

  @override
  Widget build(BuildContext context) {
    // 半屏:取屏幕宽度一半;手机上保证最小可用宽度
    final double width = max(MediaQuery.of(context).size.width * 0.5, 300);
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: const Color(0xFF1E1E20),
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text('主播列表',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close,
                            color: Colors.white54, size: 20),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white24),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (_controller.loading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Colors.white));
      }
      if (_controller.anchors.isEmpty) {
        return const Center(
            child: Text('暂无主播', style: TextStyle(color: Colors.white54)));
      }
      return ListView.separated(
        itemCount: _controller.anchors.length,
        separatorBuilder: (_, __) =>
        const Divider(height: 1, color: Colors.white12),
        itemBuilder: (context, index) => _buildRow(_controller.anchors[index]),
      );
    });
  }

  Widget _buildRow(AnchorListModel item) {
    final anchor = item.sitem;
    final urls = anchor?.picUrls ?? const <String>[];
    final levelText = anchor?.levelText ?? '';
    final subText = anchor?.subText ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // 头像:picUrl 第一条 fileUrl,点击看大图(多张可滑动)
          GestureDetector(
            onTap: anchor == null ? null : () => _openViewer(anchor),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white24,
              backgroundImage: urls.isEmpty
                  ? null
                  : CachedNetworkImageProvider(urls.first),
              child: urls.isEmpty
                  ? const Icon(Icons.person, color: Colors.white54, size: 24)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (levelText.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        Color(0xFFB14CF0),
                        Color(0xFF8A2BE2),
                      ]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.diamond_outlined,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 2),
                        Text(levelText,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                Text(anchor?.title ?? '未命名',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (subText.isNotEmpty)
                  Text(subText,
                      style:
                      const TextStyle(color: Colors.white54, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 右侧唯一按钮:移出直播间
          SizedBox(
            width: 64,
            child: OutlinedButton(
              onPressed: () => _onRemove(item),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF4D6D),
                side: const BorderSide(color: Color(0xFFFF4D6D), width: 0.8),
                padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontSize: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('移出直播间', maxLines: 1),
            ),
          ),
        ],
      ),
    );
  }
}