import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../api_request/api_configs.dart';
import '../../../models/dan_mu_model.dart';
import '../../../models/live_room_dan_mu_model.dart';
import '../../../utils/nsuserdefault.dart';

/// 服务端弹幕消息类型
class DanMuMessageType {
  /// 1: 直播间消息(在线人数/点赞/打赏等状态更新)
  static const int room = 1;

  /// 2: 互动消息(评论/送礼/点赞)
  static const int hudong = 2;

  /// 3: 游客进入直播间提示
  static const int enter = 3;
}

/// 单个直播间的弹幕控制器,通过 GetX tag = roomId 区分不同房间
class DanmuController extends GetxController {
  DanmuController({required this.roomId});

  final int roomId;

  /// 滚动弹幕列表:仅存放 type2(互动) 与 type3(进入提示)
  final RxList<DanMuModel> messages = <DanMuModel>[].obs;

  /// 直播间实时状态:存放最新一条 type1 数据(在线人数/点赞等)
  final Rxn<LiveRoomDanMuModel> roomInfo = Rxn<LiveRoomDanMuModel>();

  /// 连接状态
  final RxBool connected = false.obs;

  /// 弹幕最多保留条数,防止内存无限增长
  static const int _maxMessages = 200;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  bool _manualClose = false;
  int _reconnectAttempts = 0;

  @override
  void onInit() {
    super.onInit();
    connect();
  }

  /// 建立 WebSocket 连接
  Future<void> connect() async {
    if (connected.value) return;
    _manualClose = false;

    final url = await _buildUrl();
    if (url == null) {
      debugPrint('❌ [Danmu] 无法构建 WS 地址,baseurl 为空');
      return;
    }

    try {
      debugPrint('🔌 [Danmu] 连接房间 $roomId: $url');
      _channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        headers: {'token': await _getToken()},
      );
      await _channel!.ready;

      connected.value = true;
      _reconnectAttempts = 0;
      _startHeartbeat();

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
    } catch (e) {
      debugPrint('❌ [Danmu] 连接失败: $e');
      connected.value = false;
      _scheduleReconnect();
    }
  }

  /// 发送互动弹幕(评论)
  void send(String content) {
    final text = content.trim();
    if (text.isEmpty) return;
    if (!connected.value) {
      debugPrint('⚠️ [Danmu] 未连接,发送失败');
      return;
    }

    // 发送格式与接收 model 对称(需按后端确认)
    final payload = jsonEncode({
      'messageType': DanMuMessageType.hudong,
      'hudongMsgVo': {
        'zhiboRoomId': roomId,
        'comment': text,
      },
    });
    _channel?.sink.add(payload);
  }

  // ================= 内部实现 =================

  /// 按 messageType 分流处理
  void _onMessage(dynamic data) {
    try {
      final Map<String, dynamic> json =
          Map<String, dynamic>.from(jsonDecode(data as String) as Map);
      final DanMuModel danmu = DanMuModel.fromJson(json);
      if (danmu.messageType == 3) {
        debugPrint('⚠️ [Danmu] 收到进入提示: ${danmu.hudongMsgVo}');
      };

      switch (danmu.messageType) {
        case DanMuMessageType.room:
          // type1: 更新直播间实时状态
          if (danmu.zhiboRoomVo != null) {
            roomInfo.value = danmu.zhiboRoomVo;
          }
          break;
        case DanMuMessageType.hudong:
        case DanMuMessageType.enter:
          // type2 / type3: 加入滚动弹幕列表
          messages.add(danmu);
          if (messages.length > _maxMessages) {
            messages.removeRange(0, messages.length - _maxMessages);
          }
          break;
        default:
          debugPrint('⚠️ [Danmu] 未知消息类型: ${danmu.messageType}');
      }
    } catch (e) {
      debugPrint('⚠️ [Danmu] 消息解析失败: $e, raw=$data');
    }
  }

  Future<String?> _buildUrl() async {
    final ud = await NSUserDefault.getInstance();
    final baseUrl = ud.getValueForKey('baseurl') as String?;
    final token = await _getToken();
    // if (baseUrl == null || baseUrl.isEmpty) return null;
    // ws://api.chaopaiclub.cn//zbSocket?token=%@&roomId=%@",kUserDefaultsToken,roomId
    String socketUrl = 'ws://api.chaopaiclub.cn//zbSocket?''roomId=$roomId&token=${token ?? ''}';
    print(socketUrl);
    return 'ws://api.chaopaiclub.cn//zbSocket?'
        'roomId=$roomId&token=${token ?? ''}';
  }

  Future<String?> _getToken() async {
    final ud = await NSUserDefault.getInstance();
    return ud.getValueForKey('token') as String?;
  }

  void _onError(Object error) {
    debugPrint('❌ [Danmu] WS 错误: $error');
    connected.value = false;
  }

  void _onDone() {
    debugPrint('🔌 [Danmu] WS 已断开(房间 $roomId)');
    connected.value = false;
    _stopHeartbeat();
    if (!_manualClose) {
      _scheduleReconnect();
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: RequestConfig.danmuHeartbeatSeconds),
      (_) {
        if (connected.value) {
          _channel?.sink.add(jsonEncode({'messageType': 0, 'ping': 1}));
        }
      },
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 指数退避重连,最多 5 次
  void _scheduleReconnect() {
    if (_manualClose || _reconnectAttempts >= 5) return;
    _reconnectTimer?.cancel();
    final delay = min(pow(2, _reconnectAttempts).toInt() * 1000, 15000);
    _reconnectAttempts++;
    debugPrint('🔄 [Danmu] ${delay}ms 后第 $_reconnectAttempts 次重连');
    _reconnectTimer = Timer(Duration(milliseconds: delay), connect);
  }

  /// 主动断开(页面切走时调用)
  void disconnect() {
    _manualClose = true;
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    connected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}