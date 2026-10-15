import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../models/live_room_model.dart';
import '../pages/controller/danmu_controller.dart';
import 'add_anchor_panel.dart';
import 'anchor_list_panel.dart';
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

  @override
  void initState() {
    super.initState();
    _initializePlayer();
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
      await player.setDataSource(widget.room.httpPullUrl ?? "",
          autoPlay: widget.isActive);

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
                '播放错误: ${player.value.exception?.message ?? "未知错误"}';
          });
        }
      });

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
    setState(() {
      _isInitialized = false;
      _hasError = false;
      _errorMessage = '';
    });
    final old = _player;
    _player = null;
    await old?.release();
    await _initializePlayer();
  }

  Future<void> _pause() async {
    if (_player != null && _isInitialized) {
      await _player!.pause();
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

        // 弹幕层:仅在直播中、页面激活且控制器已注册时显示
        if (widget.room.status == 1 &&
            widget.isActive &&
            Get.isRegistered<DanmuController>(tag: _danmuTag))
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            height: 300,
            child: DanmuView(tag: _danmuTag),
          ),

        // 右下角按钮组:添加主播在左,查看主播在右,点击右侧划入对应半屏面板
        if (widget.room.status == 1 && widget.room.id != null)
          Positioned(
            right: 16,
            bottom: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
    _disposeDanmu();
    _player?.release();
    _player?.dispose();
    super.dispose();
  }
}
