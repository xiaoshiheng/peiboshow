import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import '../models/live_room_model.dart';
import '../pages/controller/danmu_controller.dart';
import '../pages/controller/live_feed_page_controller.dart';
import 'add_anchor_panel.dart';
import 'anchor_list_panel.dart';
import 'confirmed_anchor_panel.dart';
import 'danmu_view.dart';
import 'top_banner_marquee.dart';

class LiveStreamPlayer extends StatefulWidget {
  final LiveRoomModel room;
  final bool isActive;
  final VoidCallback? onDoubleTap;

  const LiveStreamPlayer({
    super.key,
    required this.room,
    required this.isActive,
    this.onDoubleTap,
  });

  @override
  State<LiveStreamPlayer> createState() => _LiveStreamPlayerState();
}

class _LiveStreamPlayerState extends State<LiveStreamPlayer> {
  FijkPlayer? _player;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  String _errorMessage = '';

  /// 轻量重建中(分辨率变化/卡顿看门狗触发,不重新拉取房间信息)
  bool _rebuilding = false;

  /// 最近一次已知的视频分辨率。主播切换清晰度会改变此值,
  /// 用作"清晰度切换"的精确检测信号。
  Size _lastVideoSize = Size.zero;

  /// 分辨率变化后的防抖重建定时器
  Timer? _sizeRebuildTimer;

  /// 卡顿看门狗:激活页应播放却长时间不出画面时自动重建
  Timer? _stallWatchdog;

  /// 连续处于"非 started"态的起始时间,用于卡顿判定
  DateTime? _stalledSince;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    // 启动卡顿看门狗,兜底处理主播切清晰度/推流抖动导致的画面冻结
    _startStallWatchdog();
    if (widget.isActive) {
      _ensureDanmu();
    }
  }

  @override
  void didUpdateWidget(LiveStreamPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _play();
        _ensureDanmu();
      } else {
        _pause();
        _disposeDanmu();
      }
    }
  }

  /// 弹幕控制器的 GetX tag(每个房间唯一)
  String get _danmuTag => 'danmu_${widget.room.id}';

  /// 确保当前房间的弹幕控制器已注册并连接
  void _ensureDanmu() {
    final roomId = widget.room.id;
    if (roomId == null) return;
    if (Get.isRegistered<DanmuController>(tag: _danmuTag)) {
      Get.find<DanmuController>(tag: _danmuTag).connect();
    } else {
      Get.put(DanmuController(roomId: roomId), tag: _danmuTag);
    }
  }

  /// 页面切走时销毁弹幕控制器,断开 WebSocket
  void _disposeDanmu() {
    if (Get.isRegistered<DanmuController>(tag: _danmuTag)) {
      Get.delete<DanmuController>(tag: _danmuTag);
    }
  }

  Future<void> _initializePlayer() async {
    try {
      final FijkPlayer player = FijkPlayer();
      _player = player;

      // 关闭硬件解码:主播切换清晰度会重配编码器(新的 SPS/PPS/分辨率),
      // 硬解(VideoToolbox/MediaCodec)无法在流中途重建解码会话 → 花屏或永久卡死;
      // 软解可容忍动态分辨率变化,是清晰度切换后能自动恢复画面的关键。
      // 注意:0.11.0 中 videotoolbox / mediacodec 均为 playerCategory 选项。
      await player.setOption(FijkOption.playerCategory, "videotoolbox", 0);
      await player.setOption(FijkOption.playerCategory, "mediacodec", 0);
      // 网络抖动/推流短暂中断时自动重连,降低清晰度切换时拉流被断开且不再恢复的概率
      await player.setOption(FijkOption.formatCategory, "reconnect", 1);
      await player.setOption(FijkOption.formatCategory, "reconnect_delay_max", 2);

      // 先注册监听器再 setDataSource,确保不漏掉 size/state 的首个回调
      player.addListener(() {
        // 旧 player 的回调不再影响新 player
        if (!mounted || _player != player) return;
        final state = player.value.state;
        final isPlaying = state == FijkState.started;
        if (isPlaying != _isPlaying) {
          setState(() => _isPlaying = isPlaying);
        }

        if (state == FijkState.error) {
          setState(() {
            _hasError = true;
            _isInitialized = false;
            _isPlaying = false;
            _errorMessage =
                '播放错误: ${player.value.exception.message ?? "未知错误"}';
          });
          return;
        }

        // 分辨率变化检测:主播切清晰度会改变视频 size(0.11.0 中 size 为 Size?)。
        // 已经出过画面后又变化 = 清晰度切换 → 防抖后轻量重建,从新关键帧重新起播。
        final newSize = player.value.size;
        if (newSize != null &&
            newSize != Size.zero &&
            newSize != _lastVideoSize) {
          final hadRendered = _lastVideoSize != Size.zero;
          _lastVideoSize = newSize;
          if (hadRendered) {
            _scheduleRebuild(delay: const Duration(milliseconds: 800));
          }
        }
      });

      await player.setDataSource(widget.room.httpPullUrl ?? "",
          autoPlay: widget.isActive);

      setState(() => _isInitialized = true);
      debugPrint('✅ Stream initialized: ${widget.room.id}');
    } catch (e) {
      debugPrint('❌ Error: $e');
      setState(() {
        _hasError = true;
        _isInitialized = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// 播放入口:错误状态下 start() 无效,必须重建播放器
  Future<void> _play() async {
    final player = _player;
    if (player == null) return;
    if (_hasError || player.value.state == FijkState.error) {
      await _retry();
      return;
    }
    if (_isInitialized) {
      await player.start();
    }
  }

  /// 释放旧播放器并重新初始化(重试)
  Future<void> _retry() async {
    await _rebuildPlayer();
  }

  /// 调度一次轻量重建(仅重连当前拉流地址,不重新拉取房间信息)。
  /// 用于主播切换清晰度导致的分辨率变化 / 流冻结恢复。
  void _scheduleRebuild({Duration delay = const Duration(milliseconds: 600)}) {
    if (_rebuilding) return;
    // 仅激活页才需要恢复 CDN 画面
    if (!widget.isActive) return;
    _sizeRebuildTimer?.cancel();
    _sizeRebuildTimer = Timer(delay, () {
      if (!mounted) return;
      if (_rebuilding) return;
      if (!widget.isActive) return;
      _rebuildPlayer();
    });
  }

  /// 释放旧播放器并用相同地址重建(清晰度切换场景 roomId 不变,无需网络重拉房间)。
  Future<void> _rebuildPlayer() async {
    if (_rebuilding) return;
    _rebuilding = true;
    _sizeRebuildTimer?.cancel();
    _stalledSince = null;
    _lastVideoSize = Size.zero;
    try {
      setState(() {
        _isInitialized = false;
        _hasError = false;
        _errorMessage = '';
      });
      final old = _player;
      _player = null;
      await old?.release();
      await _initializePlayer();
      if (mounted) setState(() {});
      debugPrint('♻️ [CDN] 清晰度切换/卡顿,已重建播放器: ${widget.room.id}');
    } finally {
      _rebuilding = false;
    }
  }

  /// 卡顿看门狗:激活且应播放的页面若长时间未进入 started 态,自动轻量重建。
  /// 兜底覆盖"size 未变但流冻结"的场景(如仅码率变化的清晰度切换)。
  void _startStallWatchdog() {
    _stallWatchdog?.cancel();
    _stallWatchdog = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final player = _player;
      if (player == null) return;
      // 离屏页 / 错误态 / 重建中 / 未初始化完成:不参与卡顿判定
      if (!widget.isActive ||
          _hasError ||
          _rebuilding ||
          !_isInitialized) {
        _stalledSince = null;
        return;
      }
      if (player.value.state == FijkState.started) {
        _stalledSince = null;
      } else {
        _stalledSince ??= DateTime.now();
        if (DateTime.now().difference(_stalledSince!) >
            const Duration(seconds: 8)) {
          _stalledSince = null;
          _scheduleRebuild(delay: Duration.zero);
        }
      }
    });
  }

  Future<void> _pause() async {
    if (_player != null && _isInitialized) {
      await _player!.pause();
    }
  }

  /// 是否正在申请成为房管,防止重复点击
  bool _becomingAdmin = false;

  /// 成为房管点击事件
  Future<void> _onBecomeAdmin() async {
    final int? roomId = widget.room.id;
    if (roomId == null || _becomingAdmin) return;
    _becomingAdmin = true;
    try {
      final LiveFeedPageController controller =
          Get.find<LiveFeedPageController>();
      final bool ok = await controller.becomeRoomAdmin(roomId.toString());
      if (!mounted) return;
      if (ok) {
        SmartDialog.showToast('成为房管成功');
        // 同步更新本地房间状态,成为房管按钮立即隐藏
        setState(() => widget.room.isAdmin = true);
      }
    } finally {
      if (mounted) _becomingAdmin = false;
    }
  }

  /// 是否正在下播,防止重复点击
  bool _offShelfing = false;

  /// 下播点击事件:二次确认后调用 offShelf 接口,成功后刷新 live_feed_page
  Future<void> _onOffShelf() async {
    final int? roomId = widget.room.id;
    if (roomId == null || _offShelfing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2C),
        title: const Text('提示',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text('确定下播 ${widget.room.roomName ?? ''} 吗?',
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

    _offShelfing = true;
    try {
      final LiveFeedPageController controller =
          Get.find<LiveFeedPageController>();
      final bool ok = await controller.offShelf(roomId.toString());
      if (!mounted) return;
      if (ok) {
        SmartDialog.showToast('下播成功');
        // 刷新直播列表,下播的房间从列表移除
        await controller.refresh();
      }
    } finally {
      if (mounted) _offShelfing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isInitialized && !_hasError && _player != null)
          FijkView(player: _player!, color: Colors.black, panelBuilder: (_, __, ___, ____, _____) => Container())
        else
          CachedNetworkImage(imageUrl: widget.room.picUrl ?? "", fit: BoxFit.cover, placeholder: (context, url) => Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: Colors.white))), errorWidget: (context, url, error) => Container(color: Colors.black, child: const Icon(Icons.error, color: Colors.white))),

        // 纯装饰渐变层:禁用命中测试,避免遮挡下层按钮点击
        IgnorePointer(
          child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.7)], stops: const [0.0, 0.3, 1.0]))),
        ),

        if (widget.room.status == 1)
          Positioned(
            left: 16,
            top: 50,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 8),
                        SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.room.roomName ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 4),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

        // 顶部滚动弹幕(类型4):红色跑马灯,多条自动排队
        if (widget.room.status == 1 &&
            widget.isActive &&
            Get.isRegistered<DanmuController>(tag: _danmuTag))
          Positioned(
            left: 0,
            right: 0,
            top: 12,
            height: 24,
            child: TopBannerMarquee(tag: _danmuTag),
          ),

        // 右上角成为房管按钮:isAdmin==true(已是当前直播间管理员)时隐藏
        if (widget.room.isAdmin != true)
          Positioned(
            right: 16,
            top: 44,
            child: ElevatedButton.icon(
              onPressed: _onBecomeAdmin,
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
              label: const Text('成为房管', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),

        // 弹幕层:仅在直播中、页面激活且控制器已注册时显示
        if (widget.room.status == 1 &&
            widget.isActive &&
            Get.isRegistered<DanmuController>(tag: _danmuTag))
          Positioned(
            left: 16,
            right: 16,
            bottom: 68,
            height: 260,
            child: DanmuView(tag: _danmuTag),
          ),

        // 右上角下播按钮:仅当已成为当前直播间管理员(isAdmin==true)时显示
        if (widget.room.status == 1 &&
            widget.room.id != null &&
            widget.room.isAdmin == true)
          Positioned(
            right: 16,
            top: 44,
            child: ElevatedButton.icon(
              onPressed: _onOffShelf,
              icon: const Icon(Icons.power_settings_new, size: 16),
              label:
                  const Text('下播', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),

        // 右下角按钮组:已确认主播在左,添加主播居中,查看主播在右,点击右侧划入对应半屏面板
        if (widget.room.status == 1 && widget.room.id != null)
          Positioned(
            right: 16,
            bottom: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context)
                      .push(ConfirmedAnchorRoute(roomId: widget.room.id!)),
                  icon: const Icon(Icons.fact_check_outlined, size: 16),
                  label:
                      const Text('已确认主播', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context)
                      .push(AddAnchorRoute(roomId: widget.room.id!)),
                  icon: const Icon(Icons.person_add_alt_outlined, size: 16),
                  label:
                      const Text('添加主播', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context)
                      .push(AnchorListRoute(roomId: widget.room.id!)),
                  icon: const Icon(Icons.people_outline, size: 16),
                  label:
                      const Text('查看主播', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ],
            ),
          ),

        // 播放失败浮层:置于 Stack 最顶层,保证重试按钮可点击
        if (_hasError)
          Positioned.fill(
            child: Container(
              color: Colors.black87,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text('播放失败',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(_errorMessage,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _retry,
                          child: const Text('重试')),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}k';
    return number.toString();
  }

  @override
  void dispose() {
    _sizeRebuildTimer?.cancel();
    _stallWatchdog?.cancel();
    _disposeDanmu();
    _player?.release();
    _player?.dispose();
    super.dispose();
  }
}
