import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../global_contoller/global_controller.dart';
import '../models/live_room_model.dart';
import '../routes/all_routes.dart';
import '../widgets/live_stream_player.dart';
import 'controller/live_feed_page_controller.dart';
import 'live_room_list_view.dart';

class LiveFeedPage extends StatefulWidget {
  const LiveFeedPage({super.key});

  @override
  State<LiveFeedPage> createState() => _LiveFeedPageState();
}

class _LiveFeedPageState extends State<LiveFeedPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  /// 处理页面切换
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 右侧抽屉: 更多直播间
      endDrawer: LiveRoomListView(
        onRoomTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
      ),
      body: GetBuilder<LiveFeedPageController>(
        id: "live_feed_page",
        builder: (controller) {
          final rooms = controller.rooms;

          // 数据为空，显示占位提示
          if (rooms == null || rooms.isEmpty) {
            return const Center(
              child: Text(
                '暂无直播间',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: rooms.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final room = rooms[index];

              return VisibilityDetector(
                key: Key('room-${room.id}-$index'),
                onVisibilityChanged: (visibilityInfo) {
                  if (visibilityInfo.visibleFraction > 0.5 &&
                      index != _currentIndex) {
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
                ),
              );
            },
          );
        },
      ),

      // 顶部导航栏
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: '退出登录',
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('退出登录'),
                content: const Text('确定要退出登录吗？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('确定', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              final globalController = Get.find<GlobalController>();
              await globalController.logout();
              Get.offAllNamed(AllRoutes.login);
            }
          },
        ),
        title: const Text(
          '直播广场',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          GetBuilder<LiveFeedPageController>(
            id: "live_feed_page",
            builder: (controller) {
              final total = controller.rooms?.length ?? 0;
              if (total == 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / $total',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            },
          ),
          // 抽屉按钮: 更多直播间
          Builder(
            builder: (context) => TextButton.icon(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu, color: Colors.white, size: 20),
              label: const Text(
                '更多直播间',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
