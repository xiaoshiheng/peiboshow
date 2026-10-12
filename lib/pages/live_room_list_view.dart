import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'controller/live_feed_page_controller.dart';

class LiveRoomListView extends StatefulWidget {
  /// 点击某个直播间时回调其下标
  final ValueChanged<int>? onRoomTap;

  const LiveRoomListView({super.key, this.onRoomTap});

  @override
  State<LiveRoomListView> createState() => _LiveRoomListViewState();
}

class _LiveRoomListViewState extends State<LiveRoomListView> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  /// 下拉刷新
  Future<void> _onRefresh() async {
    final controller = Get.find<LiveFeedPageController>();
    final ok = await controller.refresh();
    if (!ok) {
      _refreshController.refreshFailed();
      return;
    }
    _refreshController.refreshCompleted();
    if (controller.hasMore) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  /// 上拉加载更多
  Future<void> _onLoading() async {
    final controller = Get.find<LiveFeedPageController>();
    final ok = await controller.loadMore();
    if (!controller.hasMore) {
      _refreshController.loadNoData();
    } else if (ok) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadFailed();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.list, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '更多直播间',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
            Expanded(
              child: GetBuilder<LiveFeedPageController>(
                id: "live_feed_page",
                builder: (controller) {
                  final rooms = controller.rooms ?? [];
                  return SmartRefresher(
                    controller: _refreshController,
                    enablePullDown: true,
                    enablePullUp: true,
                    header: const ClassicHeader(
                      textStyle: TextStyle(color: Colors.white70),
                      idleText: '下拉刷新',
                      releaseText: '释放立即刷新',
                      refreshingText: '刷新中...',
                      completeText: '刷新完成',
                    ),
                    footer: const ClassicFooter(
                      textStyle: TextStyle(color: Colors.white70),
                      loadingText: '加载中...',
                      noDataText: '没有更多直播间了',
                    ),
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: rooms.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                child: Text(
                                  '暂无直播间',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            itemCount: rooms.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, color: Colors.white12),
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              return ListTile(
                                leading: room.picUrl == null
                                    ? const CircleAvatar(
                                        backgroundColor: Colors.white24,
                                        child: Icon(Icons.live_tv,
                                            color: Colors.white54, size: 20),
                                      )
                                    : CircleAvatar(
                                        backgroundColor: Colors.white24,
                                        backgroundImage:
                                            NetworkImage(room.picUrl!),
                                      ),
                                title: Text(
                                  room.roomName ?? '未命名直播间',
                                  style: const TextStyle(color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${room.companyName ?? ''}  ${room.onlineMemberCount ?? 0} 人在线',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.chevron_right,
                                    color: Colors.white38),
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onRoomTap?.call(index);
                                },
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
