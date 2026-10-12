import 'package:flutter/material.dart';
import '../models/live_room_model.dart';
import '../pages/live_feed_page.dart';

/// 网易云信直播间数据服务
class NeteaseLiveService {
  /// 从网易云信获取拉流地址
  /// 
  /// 实际使用时需要:
  /// 1. 注册网易云信账号
  /// 2. 创建应用获取AppKey和AppSecret
  /// 3. 调用服务端API生成拉流地址
  static Future<List<LiveRoomModel>> fetchLiveRooms() async {
    // 模拟数据 - 实际项目中替换为真实API调用
    return [
      LiveRoomModel(
        roomId: 'room_001',
        roomName: '游戏直播 - LOL排位赛',
        anchorName: '电竞小王',
        avatarUrl: 'https://picsum.photos/seed/avatar1/200/200',
        // 公开测试FLV流(用于验证media_kit是否正常)
        streamUrl: 'https://flva4577897.live.126.net/live/27a1d2bd0557427f838065467aee10be.flv?netease=flva4577897.live.126.net',
        coverUrl: 'https://picsum.photos/seed/cover1/720/1280',
        onlineUsers: 12580,
        streamType: 'flv',
        isLive: true,
        tags: ['游戏', 'LOL', '排位赛'],
      ),
      LiveRoomModel(
        roomId: 'room_002',
        roomName: '唱歌聊天 - 点歌台',
        anchorName: '音乐小仙女',
        avatarUrl: 'https://picsum.photos/seed/avatar2/200/200',
        // HLS拉流地址(iOS/Android通用)
        streamUrl: 'https://flva4577897.live.126.net/live/5968f253af1e451ebc789e44d149c1db.flv?netease=flva4577897.live.126.net',
        coverUrl: 'https://picsum.photos/seed/cover2/720/1280',
        onlineUsers: 8934,
        streamType: 'flv', // ✅ 保持 hls
        isLive: true,
        tags: ['音乐', '唱歌', '聊天'],
      ),
      LiveRoomModel(
        roomId: 'room_003',
        roomName: '美食制作 - 川菜教学',
        anchorName: '大厨老张',
        avatarUrl: 'https://picsum.photos/seed/avatar3/200/200',
        // FLV拉流地址(低延迟)
        streamUrl: 'https://flva4577897.live.126.net/live/1f143ce9a9b245ea9d1781ae6f62ffb7.flv?netease=flva4577897.live.126.net',
        coverUrl: 'https://picsum.photos/seed/cover3/720/1280',
        onlineUsers: 5623,
        streamType: 'hls',
        isLive: true,
        tags: ['美食', '烹饪', '教学'],
      ),
      LiveRoomModel(
        roomId: 'room_004',
        roomName: '户外旅行 - 西藏自驾游',
        anchorName: '旅行者阿明',
        avatarUrl: 'https://picsum.photos/seed/avatar4/200/200',
        streamUrl: 'https://pullhlsa4577897.live.126.net/live/11092e5af5794bbcb98159c8d0332468/playlist.m3u8',
        coverUrl: 'https://picsum.photos/seed/cover4/720/1280',
        onlineUsers: 15234,
        streamType: 'hls',
        isLive: true,
        tags: ['旅行', '户外', '自驾'],
      ),
      LiveRoomModel(
        roomId: 'room_005',
        roomName: '健身打卡 - 减脂训练',
        anchorName: '健身教练Lisa',
        avatarUrl: 'https://picsum.photos/seed/avatar5/200/200',
        streamUrl: 'https://pullhlsa4577897.live.126.net/live/dd2ef9f25f7944f9afe188df2b09843e/playlist.m3u8',
        coverUrl: 'https://picsum.photos/seed/cover5/720/1280',
        onlineUsers: 9876,
        streamType: 'hls',
        isLive: true,
        tags: ['健身', '减脂', '运动'],
      ),
    ];
  }

  /// 实际项目中调用网易云信API的示例
  static Future<List<LiveRoomModel>> fetchFromNeteaseAPI() async {
    // 伪代码 - 实际需要实现HTTP请求
    /*
    final response = await http.get(
      Uri.parse('https://api.netease.im/nimserver/chatroom/get.action'),
      headers: {
        'AppKey': 'your_app_key',
        'Nonce': 'random_string',
        'CurTime': 'timestamp',
        'CheckSum': 'md5(app_secret + nonce + curtime)',
      },
    );
    
    final data = json.decode(response.body);
    return (data['chatrooms'] as List)
        .map((json) => LiveRoomModel.fromJson(json))
        .toList();
    */
    
    return [];
  }
}

/// 直播间列表页面入口
class LiveRoomsScreen extends StatelessWidget {
  const LiveRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('网易云信直播'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text(
              '网易云信直播流滑动切换',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '支持 RTMP / HLS / FLV 格式',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                // 加载直播间数据
                final rooms = await NeteaseLiveService.fetchLiveRooms();
                
                // 跳转到Feed页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LiveFeedPage(rooms: rooms),
                  ),
                );
              },
              icon: Icon(Icons.play_arrow),
              label: Text('进入直播广场'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
