import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/live_room_model.dart';
import '../widgets/live_stream_player.dart';

class LiveFeedPage extends StatefulWidget {
  final List<LiveRoomModel> rooms;

  const LiveFeedPage({
    super.key,
    required this.rooms,
  });

  @override
  State<LiveFeedPage> createState() => _LiveFeedPageState();
}

class _LiveFeedPageState extends State<LiveFeedPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentIndex = 0;
  }

  /// 处理页面切换
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    print('Switched to room: ${widget.rooms[index].roomName} (index: $index)');
  }

  /// 获取真实的房间数据
  LiveRoomModel _getRoom(int index) {
    return widget.rooms[index];
  }

  /// 双击点赞
  void _handleLike() {
    final room = _getRoom(_currentIndex);
    print('Liked room: ${room.roomName}');

    // TODO: 调用点赞API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已给 ${room.anchorName} 点赞 ❤️'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red.withOpacity(0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.rooms.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final room = _getRoom(index);

          return VisibilityDetector(
            key: Key('room-${room.roomId}-$index'),
            onVisibilityChanged: (visibilityInfo) {
              if (visibilityInfo.visibleFraction > 0.5 && index != _currentIndex) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
            child: LiveStreamPlayer(
              room: room,
              isActive: index == _currentIndex,
              onDoubleTap: _handleLike,
            ),
          );
        },
      ),

      // 顶部导航栏
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '直播广场',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.rooms.length}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
