import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../models/confirmed_anchor_model.dart';
import '../models/confirmed_anchor_model_ext.dart';
import 'controller/anchor_list_controller.dart';

/// 已确认主播路由:从右侧划入
class ConfirmedAnchorRoute extends PopupRoute<void> {
  ConfirmedAnchorRoute({required this.roomId});

  final int roomId;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'confirmed_anchor';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) =>
      ConfirmedAnchorPanel(roomId: roomId);

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

/// 半屏已确认主播面板:表格展示 预约时间/预约人/集合地/会员名称
class ConfirmedAnchorPanel extends StatefulWidget {
  final int roomId;

  const ConfirmedAnchorPanel({super.key, required this.roomId});

  @override
  State<ConfirmedAnchorPanel> createState() => _ConfirmedAnchorPanelState();
}

class _ConfirmedAnchorPanelState extends State<ConfirmedAnchorPanel> {
  /// 面板背景色(与 AnchorListPanel/AddAnchorPanel 一致)
  static const Color _bg = Color(0xFF1E1E20);

  /// 选中/强调色(与 AnchorListPanel/AddAnchorPanel 一致)
  static const Color _accent = Color(0xFFFF4D6D);

  /// 表格线颜色
  static const Color _border = Colors.white24;

  /// 表头背景色
  static const Color _headerBg = Colors.white10;

  /// 搜索栏高度:搜索框与筛选按钮共用,保证高度一致且内容垂直居中
  static const double _barHeight = 38;

  String get _tag => 'confirmed_anchor_${widget.roomId}';

  /// 每次打开面板新建控制器(autoLoad=false 不请求主播列表),关闭时销毁
  late final AnchorListController _controller = Get.put(
      AnchorListController(roomId: widget.roomId, autoLoad: false),
      tag: _tag);

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  /// 搜索关键词(本地按会员名 itemName 过滤,不请求接口)
  String _keyword = '';

  /// 是否到场筛选:null=全部, 1=已到场, 0=未到场
  int? _arriveFilter;

  @override
  void initState() {
    super.initState();
    _controller.confirmAnchor();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _refreshController.dispose();
    Get.delete<AnchorListController>(tag: _tag);
    super.dispose();
  }

  /// 本地搜索:通过会员名 itemName 过滤 + 是否到场筛选
  List<ConfirmedAnchorModel> get _filteredList {
    List<ConfirmedAnchorModel> list = _controller.confirmedAnchors;
    if (_keyword.isNotEmpty) {
      list = list.where((e) => (e.itemName ?? '').contains(_keyword)).toList();
    }
    if (_arriveFilter != null) {
      list = list.where((e) => e.arriveFlag == _arriveFilter).toList();
    }
    return list;
  }

  void _onSearchChanged(String value) {
    setState(() => _keyword = value.trim());
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    final bool ok = await _controller.confirmAnchor();
    if (ok) {
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 半屏:列数较多,适当加宽;手机上保证最小可用宽度
    final double width = max(MediaQuery.of(context).size.width * 0.55, 340);
    return Align(
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
                _buildTitleBar(),
                const Divider(height: 1, color: Colors.white24),
                _buildSearchBar(),
                const Divider(height: 1, color: Colors.white24),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 标题栏:图标 + 已确认会员 + 右上角关闭(与 AnchorListPanel 一致)
  Widget _buildTitleBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.fact_check_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text('已确认主播',
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white54, size: 20),
          ),
        ],
      ),
    );
  }

  /// 搜索栏:深色输入框 + 右侧是否到场筛选(本地过滤)
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: _barHeight,
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
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: '请输入',
                        hintStyle:
                            TextStyle(fontSize: 13, color: Colors.white38),
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
          _buildArriveFilter(),
        ],
      ),
    );
  }

  /// 是否到场筛选按钮:全部/已到场/未到场,默认全部(与搜索框同高,文字垂直居中)
  Widget _buildArriveFilter() {
    final String label =
        _arriveFilter == null ? '全部' : (_arriveFilter == 1 ? '已到场' : '未到场');
    return PopupMenuButton<int>(
      color: _bg,
      offset: Offset(0, _barHeight + 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) =>
          setState(() => _arriveFilter = value == -1 ? null : value),
      itemBuilder: (context) => [
        _arriveMenuItem(-1, '全部'),
        _arriveMenuItem(1, '已到场'),
        _arriveMenuItem(0, '未到场'),
      ],
      child: Container(
        height: _barHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 13, color: _accent)),
            const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  /// 筛选菜单项:选中项以强调色 + 对勾高亮
  PopupMenuItem<int> _arriveMenuItem(int value, String text) {
    final bool selected =
        (_arriveFilter == null && value == -1) || _arriveFilter == value;
    return PopupMenuItem<int>(
      value: value,
      height: 36,
      child: Row(
        children: [
          Text(
            text,
            style:
                TextStyle(fontSize: 13, color: selected ? _accent : Colors.white),
          ),
          const Spacer(),
          if (selected) const Icon(Icons.check, size: 14, color: _accent),
        ],
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
    if (_controller.confirmedLoading.value &&
        _controller.confirmedAnchors.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white)),
          ),
        ],
      );
    }
    final List<ConfirmedAnchorModel> list = _filteredList;
    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          Center(
            child: Text('暂无数据', style: TextStyle(color: Colors.white54)),
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [_buildTable(list)],
    );
  }

  /// 六列表格:序号/预约时间/预约人/集合地/主播名称/是否到场
  Widget _buildTable(List<ConfirmedAnchorModel> list) {
    return Table(
      border: TableBorder.all(color: _border, width: 0.8),
      defaultColumnWidth: const FlexColumnWidth(1),
      columnWidths: const {
        0: FlexColumnWidth(0.4),
        5: FlexColumnWidth(0.8),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: _headerBg),
          children: [
            _HeaderCell('序号'),
            _HeaderCell('预约时间'),
            _HeaderCell('预约人'),
            _HeaderCell('集合地'),
            _HeaderCell('主播名称'),
            _HeaderCell('是否到场'),
          ],
        ),
        ...list.asMap().entries.map(
              (entry) => TableRow(
            children: [
              _Cell('${list.length - entry.key}'),
              _Cell(entry.value.preOrderTimeHM),
              _Cell(entry.value.managerName ?? ''),
              _Cell(entry.value.roomName0 ?? ''),
              _Cell(entry.value.itemName ?? ''),
              _Cell(
                entry.value.arriveFlag == 1 ? '已到场' : '未到场',
                color: entry.value.arriveFlag == 1 ? null : Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 表头单元格:加粗居中
class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// 数据单元格:居中,超长省略
class _Cell extends StatelessWidget {
  final String text;
  final Color? color;

  const _Cell(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color ?? Colors.white70, fontSize: 13),
      ),
    );
  }
}