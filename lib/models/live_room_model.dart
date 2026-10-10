class LiveRoomModel {
  final String roomId;
  final String roomName;
  final String anchorName; // 主播名称
  final String avatarUrl; // 主播头像
  final String streamUrl; // 网易云信拉流地址(RTMP/HLS/FLV)
  final String coverUrl; // 封面图
  final int onlineUsers; // 在线人数
  final String streamType; // 流类型: rtmp, hls, flv
  final bool isLive; // 是否正在直播
  final List<String> tags; // 标签

  LiveRoomModel({
    required this.roomId,
    required this.roomName,
    required this.anchorName,
    required this.avatarUrl,
    required this.streamUrl,
    required this.coverUrl,
    this.onlineUsers = 0,
    this.streamType = 'hls',
    this.isLive = true,
    this.tags = const [],
  });

  factory LiveRoomModel.fromJson(Map<String, dynamic> json) {
    return LiveRoomModel(
      roomId: json['roomId'] as String,
      roomName: json['roomName'] as String,
      anchorName: json['anchorName'] as String,
      avatarUrl: json['avatarUrl'] as String,
      streamUrl: json['streamUrl'] as String,
      coverUrl: json['coverUrl'] as String,
      onlineUsers: json['onlineUsers'] as int? ?? 0,
      streamType: json['streamType'] as String? ?? 'hls',
      isLive: json['isLive'] as bool? ?? true,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'anchorName': anchorName,
      'avatarUrl': avatarUrl,
      'streamUrl': streamUrl,
      'coverUrl': coverUrl,
      'onlineUsers': onlineUsers,
      'streamType': streamType,
      'isLive': isLive,
      'tags': tags,
    };
  }
}
