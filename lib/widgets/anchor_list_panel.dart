import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  /// 下拉刷新控制器
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    Get.delete<AnchorListController>(tag: _tag);
    super.dispose();
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    final bool ok = await _controller.getAnchorList();
    if (ok) {
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  /// 点击筛选按钮
  Future<void> _onFilterTap(int? value) async {
    final bool ok = await _controller.setLikeFilter(value);
    if (!ok) {
      SmartDialog.showToast('筛选失败');
    }
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
        content: Text('确定将 $name 移出才艺间吗?',
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
      SmartDialog.showToast('已移出才艺间');
      _controller.getAnchorList();
    } else {
      SmartDialog.showToast('移出才艺间失败');
    }
  }

  /// 确认前往(managerId>0 时显示)
  Future<void> _onConfirmGo(AnchorListModel item) async {
    final name = item.roomName0 ?? '';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2C),
        title: const Text('提示',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text('确定前往 $name 吗?',
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确定',
                  style: TextStyle(color: Color(0xFF2ECC71)))),
        ],
      ),
    );
    if (confirm != true) return;

    final ok = await _controller.likeAnchor(item);
    if (ok) {
      SmartDialog.showToast('已确认前往');
      _controller.getAnchorList();
    } else {
      SmartDialog.showToast('确认前往失败');
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
                _buildFilterBar(),
                const Divider(height: 1, color: Colors.white24),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 顶部筛选栏:全部 / 已一见倾心 / 未一见倾心
  Widget _buildFilterBar() {
    return Obx(() {
      final int? current = _controller.likeFilter.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _buildFilterChip('全部', null, current),
            const SizedBox(width: 8),
            _buildFilterChip('已一见倾心', 1, current),
            const SizedBox(width: 8),
            _buildFilterChip('未一见倾心', 0, current),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip(String label, int? value, int? current) {
    final bool selected = current == value;
    return GestureDetector(
      onTap: () => _onFilterTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF4D6D) : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFFF4D6D) : Colors.white24,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      return SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: false,
        header: const ClassicHeader(
          textStyle: TextStyle(color: Colors.white70),
          idleText: '下拉刷新',
          releaseText: '释放立即刷新',
          refreshingText: '刷新中...',
          completeText: '刷新完成',
          failedText: '刷新失败',
        ),
        onRefresh: _onRefresh,
        child: _buildList(),
      );
    });
  }

  /// SmartRefresher 的 child 必须直接是可滚动组件(ScrollView),
  /// 不能被 Obx/GetBuilder 包裹,否则会形成嵌套滚动导致下拉刷新失效
  Widget _buildList() {
    // 首次加载(列表为空且加载中)显示转圈
    if (_controller.loading.value && _controller.anchors.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      );
    }
    if (_controller.anchors.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          Center(
            child: Text('暂无主播', style: TextStyle(color: Colors.white54)),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _controller.anchors.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, color: Colors.white12),
      itemBuilder: (context, index) {
        AnchorListModel item = _controller.anchors[index];
          return _buildRow(item);
        return const SizedBox.shrink();
      }
          // _buildRow(_controller.anchors[index]),
    );
  }

  Widget _buildRow(AnchorListModel item) {
    final anchor = item.sitem;
    final urls = anchor?.picUrls ?? const <String>[];
    final levelText = anchor?.levelText ?? '';
    final bool hasManager = (item.managerId ?? 0) > 0;

    /// 第一行后缀:等级 + 年龄 + 身高,如「永恒钻石 27岁 165cm」
    final String suffix = [
      if (levelText.isNotEmpty) levelText,
      if (anchor?.age != null) '${anchor!.age}岁',
      if (anchor?.height != null) '${anchor!.height}cm',
    ].join(' ');

    /// 第二行:一见倾心红心标记 + 房间 · 房管 · 下单时间
    final String infoLine = [
      item.roomName0 ?? '',
      item.managerName ?? '',
      item.orderTimeHM,
    ].where((s) => s.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // 头像:picUrl 第一条 fileUrl,点击看大图(多张可滑动)
          GestureDetector(
            onTap: anchor == null ? null : () => _openViewer(anchor),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white24,
              backgroundImage: urls.isEmpty
                  ? null
                  : CachedNetworkImageProvider(urls.first),
              child: urls.isEmpty
                  ? const Icon(Icons.person, color: Colors.white54, size: 28)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 第一行:昵称 ·等级 年龄
                Row(
                  children: [
                    Flexible(
                      child: Text(anchor?.title ?? '未命名',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (suffix.isNotEmpty)
                      Text(' ·$suffix',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
                // 第二行:一见倾心红心标记 + 房间 · 房管 · 下单时间
                if (infoLine.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.favorite,
                          color: Color(0xFFFF4D6D), size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(infoLine,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 右侧按钮区:managerId>0(一见倾心) 时额外显示绿色"确认前往"按钮
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasManager) ...[
                SizedBox(
                  width: 68,
                  child: ElevatedButton(
                    onPressed: () => _onConfirmGo(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(fontSize: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('确认前往', maxLines: 1),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              SizedBox(
                width: 68,
                child: ElevatedButton(
                  onPressed: () => _onRemove(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D6D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontSize: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('移除', maxLines: 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}