import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/live_feed_page_controller.dart';

class LiveRoomListView extends StatelessWidget {
  /// 点击某个直播间时回调其下标
  final ValueChanged<int>? onRoomTap;

  const LiveRoomListView({super.key, this.onRoomTap});

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
                builder: (controller) {
                  final rooms = controller.rooms ?? [];
                  if (rooms.isEmpty) {
                    return const Center(
                      child: Text(
                        '暂无直播间',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }
                  return ListView.separated(
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
                                backgroundImage: NetworkImage(room.picUrl!),
                              ),
                        title: Text(
                          room.roomName ?? '未命名直播间',
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${room.companyName ?? ''}  ${room.onlineMemberCount ?? 0} 人在线',
                          style:
                              const TextStyle(color: Colors.white54, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right,
                            color: Colors.white38),
                        onTap: () {
                          Navigator.pop(context);
                          onRoomTap?.call(index);
                        },
                      );
                    },
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
