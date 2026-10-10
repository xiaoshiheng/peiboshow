import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/live_room_model.dart';

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
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(LiveStreamPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _play();
      } else {
        _pause();
      }
    }
  }

  Future<void> _initializePlayer() async {
    try {
      debugPrint('🔄 Initializing stream (${widget.room.streamType}): ${widget.room.streamUrl}');

      _player = FijkPlayer();
      await _player!.setDataSource(widget.room.streamUrl, autoPlay: widget.isActive);
      
      _player!.addListener(() {
        if (!mounted) return;
        final state = _player!.value.state;
        final isPlaying = state == FijkState.started;
        if (isPlaying != _isPlaying) {
          setState(() => _isPlaying = isPlaying);
        }
        if (state == FijkState.error) {
          setState(() {
            _hasError = true;
            _errorMessage = '播放错误: ${_player!.value.exception?.message ?? "未知错误"}';
          });
        }
      });

      setState(() => _isInitialized = true);
      debugPrint('✅ Stream initialized: ${widget.room.roomId}');
    } catch (e) {
      debugPrint('❌ Error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _play() async {
    if (_player != null && _isInitialized) {
      await _player!.start();
    }
  }

  Future<void> _pause() async {
    if (_player != null && _isInitialized) {
      await _player!.pause();
    }
  }

  void _handleDoubleTap() {
    setState(() => _showHeart = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showHeart = false);
    });
    widget.onDoubleTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      onTap: () {
        if (_isPlaying) {
          _pause();
        } else {
          _play();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized && !_hasError && _player != null)
            FijkView(player: _player!, color: Colors.black, panelBuilder: (_, __, ___, ____, _____) => Container())
          else if (_hasError)
            Container(
              color: Colors.black87,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text('播放失败', style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(_errorMessage, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: () { setState(() { _isInitialized = false; _hasError = false; }); _player?.release(); _player?.dispose(); _initializePlayer(); }, child: const Text('重试')),
                    ],
                  ),
                ),
              ),
            )
          else
            CachedNetworkImage(imageUrl: widget.room.coverUrl, fit: BoxFit.cover, placeholder: (context, url) => Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: Colors.white))), errorWidget: (context, url, error) => Container(color: Colors.black, child: const Icon(Icons.error, color: Colors.white))),

          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.7)], stops: const [0.0, 0.3, 1.0]))),

          if (_showHeart) Center(child: AnimatedOpacity(opacity: _showHeart ? 1.0 : 0.0, duration: const Duration(milliseconds: 300), child: const Icon(Icons.favorite, color: Colors.red, size: 100))),

          if (widget.room.isLive) Positioned(left: 16, top: 50, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, color: Colors.white, size: 8), SizedBox(width: 4), Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]))),

          Positioned(left: 16, right: 80, bottom: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.room.avatarUrl)), const SizedBox(width: 8), Expanded(child: Text(widget.room.anchorName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 8), Text(widget.room.roomName, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis), if (widget.room.tags.isNotEmpty) ...[const SizedBox(height: 8), Wrap(spacing: 6, children: widget.room.tags.map((tag) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 11)))).toList())]])),

          Positioned(right: 12, bottom: 100, child: Column(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(15)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.visibility, color: Colors.white, size: 16), const SizedBox(width: 4), Text(_formatNumber(widget.room.onlineUsers), style: const TextStyle(color: Colors.white, fontSize: 12))])), const SizedBox(height: 16), _ActionButton(icon: Icons.favorite, label: '点赞', color: Colors.red), const SizedBox(height: 16), _ActionButton(icon: Icons.chat_bubble, label: '弹幕'), const SizedBox(height: 16), _ActionButton(icon: Icons.share, label: '分享')])),

          if (!_isPlaying && _isInitialized) Center(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle), child: const Icon(Icons.play_arrow, color: Colors.white, size: 48))),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}k';
    return number.toString();
  }

  @override
  void dispose() {
    _player?.release();
    _player?.dispose();
    super.dispose();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: color ?? Colors.white, size: 28)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: Colors.white, fontSize: 12))]);
  }
}
