import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../models/add_anchor_model.dart';
import '../models/add_anchor_model_ext.dart';
import 'controller/add_anchor_controller.dart';

/// 添加主播路由:从右侧划入
class AddAnchorRoute extends PopupRoute<void> {
  AddAnchorRoute({required this.roomId});

  final int roomId;

  @override
  Color? get barrierColor => Colors.black54;

  // 遮罩不再自动关闭页面,关闭逻辑交由面板内点击层按搜索框输入状态分发
  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'add_anchor';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) =>
      AddAnchorPanel(roomId: roomId);

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

/// 半屏添加主播面板
class AddAnchorPanel extends StatefulWidget {
  final int roomId;

  const AddAnchorPanel({super.key, required this.roomId});

  @override
  State<AddAnchorPanel> createState() => _AddAnchorPanelState();
}

class _AddAnchorPanelState extends State<AddAnchorPanel> {
  /// 面板背景色(与 AnchorListPanel 一致)
  static const Color _bg = Color(0xFF1E1E20);

  /// 选中/强调色(与 AnchorListPanel 一致)
  static const Color _accent = Color(0xFFFF4D6D);

  String get _tag => 'add_anchor_${widget.roomId}';

  /// 每次打开面板新建控制器,关闭时销毁
  late final AddAnchorController _controller =
      Get.put(AddAnchorController(roomId: widget.roomId), tag: _tag);

  final TextEditingController _searchController = TextEditingController();

  /// 搜索框焦点,用于判断是否处于输入状态
  final FocusNode _searchFocusNode = FocusNode();

  /// 下拉刷新控制器
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  /// 搜索关键词(本地过滤,不请求接口)
  String _keyword = '';

  /// 已选主播 id 集合
  final Set<int> _selectedIds = <int>{};

  /// 是否正在提交添加,防止重复点击
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // loading 为控制器 RxBool,由 Obx 监听,无需本地加载状态
    _controller.getAnchorList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _refreshController.dispose();
    Get.delete<AddAnchorController>(tag: _tag);
    super.dispose();
  }

  /// 本地搜索:直接过滤 anchorList 中 name 包含搜索词的数据
  List<AddAnchorModel> get _filteredList {
    final list = _controller.anchorList;
    if (_keyword.isEmpty) return list;
    return list.where((e) => (e.name ?? '').contains(_keyword)).toList();
  }

  void _onSearchChanged(String value) {
    setState(() => _keyword = value.trim());
  }

  void _onSearchTap() {
    _searchFocusNode.unfocus();
  }

  /// 点击面板外空白:搜索框聚焦时只收回键盘,未聚焦才关闭面板
  void _onBarrierTap() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _toggleItem(AddAnchorModel item) {
    final int id = item.id ?? 0;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  /// 当前搜索结果是否已全部选中
  bool get _isAllSelected {
    final list = _filteredList;
    return list.isNotEmpty &&
        list.every((e) => _selectedIds.contains(e.id ?? 0));
  }

  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        for (final e in _filteredList) {
          _selectedIds.remove(e.id ?? 0);
        }
      } else {
        for (final e in _filteredList) {
          _selectedIds.add(e.id ?? 0);
        }
      }
    });
  }

  Future<void> _onConfirmAdd() async {
    if (_selectedIds.isEmpty || _submitting) return;
    _submitting = true;
    try {
      final bool ok = await _controller.addAnchor(_selectedIds.toList());
      if (!mounted) return;
      if (ok) {
        SmartDialog.showToast('添加成功');
        _selectedIds.clear();
        await _controller.getAnchorList();
      } else {
        SmartDialog.showToast('添加失败');
        _selectedIds.clear();
        await _controller.getAnchorList();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 半屏:取屏幕宽度一半;手机上保证最小可用宽度
    final double width = max(MediaQuery.of(context).size.width * 0.5, 300);
    return Stack(
      fit: StackFit.expand,
      children: [
        // 遮罩点击层:接管面板外空白的点击,按输入状态分发
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onBarrierTap,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: _bg,
            child: SizedBox(
              width: width,
              height: double.infinity,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSearchBar(),
                    const Divider(height: 1, color: Colors.white24),
                    Expanded(child: _buildBody()),
                    _buildBottomBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 顶部搜索栏:深色输入框 + 搜索按钮(本地过滤,不请求接口)
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white54, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _onSearchChanged,
                      onSubmitted: (_) => _onSearchTap(),
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: '请输入艺名搜索',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.white38),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _onSearchTap,
            child: const Text(
              '搜索',
              style: TextStyle(fontSize: 15, color: _accent),
            ),
          ),
        ],
      ),
    );
  }

  /// 列表区:Obx 监听控制器 loading,SmartRefresher 提供下拉刷新
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
    if (_controller.loading.value && _controller.anchorList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      );
    }
    final list = _filteredList;
    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          Center(
            child:
                Text('暂无主播', style: TextStyle(color: Colors.white54)),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Colors.white12),
      itemBuilder: (context, index) => _buildRow(list[index]),
    );
  }

  /// 列表行:复选框 + 头像 + 艺名/编号/等级/状态
  Widget _buildRow(AddAnchorModel item) {
    final bool selected = _selectedIds.contains(item.id ?? 0);
    return InkWell(
      onTap: () => _toggleItem(item),
      child: Container(
        color: selected ? Colors.white10 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => _toggleItem(item),
              activeColor: _accent,
              checkColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            // 头像:与 AnchorListPanel 一致,取 picUrl 第一条 fileUrl,不点击看大图
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white24,
              backgroundImage: item.avatarUrl.isEmpty
                  ? null
                  : CachedNetworkImageProvider(item.avatarUrl),
              child: item.avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white54, size: 24)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name ?? '未命名',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.userNo != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          'No.${item.userNo}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.level ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.processCN ?? ''}/${item.statusCN ?? ''}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 底部栏:全选 + 已选人数 + 确认添加
  Widget _buildBottomBar() {
    final bool allSelected = _isAllSelected;
    final bool canConfirm = _selectedIds.isNotEmpty && !_submitting;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, color: Colors.white24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Checkbox(
                value: allSelected,
                onChanged: (_) => _toggleSelectAll(),
                activeColor: _accent,
                checkColor: Colors.white,
                shape: const CircleBorder(),
                side: const BorderSide(color: Colors.white38),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              GestureDetector(
                onTap: _toggleSelectAll,
                child: const Text(
                  '全选',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '已选 ${_selectedIds.length} 人',
                style: const TextStyle(fontSize: 13, color: Colors.white54),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: canConfirm ? _onConfirmAdd : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white10,
                  disabledForegroundColor: Colors.white38,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('确认添加', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    final bool ok = await _controller.getAnchorList();
    if (ok) {
      _refreshController.refreshCompleted();
      setState(() => _selectedIds.clear());
    } else {
      _refreshController.refreshFailed();
    }
  }
}