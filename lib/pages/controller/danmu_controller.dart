import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../api_request/api_configs.dart';
import '../../../models/dan_mu_model.dart';
import '../../../models/live_room_dan_mu_model.dart';
import '../../../utils/nsuserdefault.dart';
import 'live_feed_page_controller.dart';

/// 服务端弹幕消息类型
class DanMuMessageType {
  /// 1: 直播间消息(在线人数/点赞/打赏等状态更新)
  static const int room = 1;

  /// 2: 互动消息(评论/送礼/点赞)
  static const int hudong = 2;

  /// 3: 游客进入直播间提示
  static const int enter = 3;

  /// 4: vip会员进入直播间提示
  static const int vipEnter = 4;
}

/// 单个直播间的弹幕控制器,通过 GetX tag = roomId 区分不同房间
class DanmuController extends GetxController {
  DanmuController({required this.roomId});

  final int roomId;

  /// 滚动弹幕列表:仅存放 type2(互动) 与 type3(进入提示)
  final RxList<DanMuModel> messages = <DanMuModel>[].obs;

  /// 直播间实时状态:存放最新一条 type1 数据(在线人数/点赞等)
  final Rxn<LiveRoomDanMuModel> roomInfo = Rxn<LiveRoomDanMuModel>();

  /// 顶部滚动弹幕(类型4)当前正在展示的内容,null 表示无
  final Rxn<String> topBanner = Rxn<String>();

  /// 顶部滚动弹幕等待队列:正在滚动时新到的类型4消息在此排队
  final List<String> _bannerQueue = <String>[];

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

  /// 是否已弹出"直播间已下播"提示,避免重复弹框
  bool _offShelfDialogShown = false;

  @override
  void onInit() {
    super.onInit();
    connect();
  }

  /// 建立 WebSocket 连接
  /// [force] 为 true 时无视当前 connected 状态,先彻底释放旧连接再重连,
  /// 并重置重连计数,用于连接假死 / 重连次数耗尽后的强制恢复。
  Future<void> connect({bool force = false}) async {
    if (!force && connected.value) return;
    if (force) {
      await _closeChannel();
      _reconnectAttempts = 0;
    }
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

  /// 顶部弹幕滚动结束:由视图层动画完成时回调,展示队列中的下一条
  void onTopBannerFinished() {
    topBanner.value = null;
    _showNextTopBanner();
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
      if (danmu.messageType == 4) {
        debugPrint('⚠️ [Danmu] 收到进入提示: ${danmu.content}');
      }
      switch (danmu.messageType) {
        case DanMuMessageType.room:
          // type1: 更新直播间实时状态
          if (danmu.zhiboRoomVo != null) {
            roomInfo.value = danmu.zhiboRoomVo;
            // status != 1 表示直播间已下播:弹全屏遮罩框,阻止滑动切换,确定后刷新列表
            if (danmu.zhiboRoomVo?.status != 1) {
              _showOffShelfDialog();
            }
          }
          break;
        case DanMuMessageType.hudong:
        case DanMuMessageType.enter:
          // type2 / type3:加入滚动弹幕列表
          messages.add(danmu);
          if (messages.length > _maxMessages) {
            messages.removeRange(0, messages.length - _maxMessages);
          }
          break;
        case DanMuMessageType.vipEnter:
          // type4:①仅 bizType==3(预约谁) 才上直播间顶部滚动弹幕,多条时排队等待
          if (danmu.bizType == 3) {
            _enqueueTopBanner(danmu.content ?? '');
          }
          // ②同时加入底部弹幕列表展示
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

  /// 收到类型4弹幕:入队,若当前无滚动则立即展示
  void _enqueueTopBanner(String content) {
    final String text = content.trim();
    if (text.isEmpty) return;
    _bannerQueue.add(text);
    _showNextTopBanner();
  }

  /// 展示队列中的下一条(仅当前无滚动时切换,否则排队等待)
  void _showNextTopBanner() {
    if (topBanner.value != null) return; // 正在滚动,排队等待
    if (_bannerQueue.isEmpty) return;
    topBanner.value = _bannerQueue.removeAt(0);
  }

  /// 弹出全屏遮罩提示:该直播间已下播
  /// 遮罩铺满全屏且不可点击外部关闭,阻止用户滑动切换直播间;
  /// 点击"确定"后关闭弹框并调用 LiveFeedPageController.refresh() 刷新列表
  void _showOffShelfDialog() {
    if (_offShelfDialogShown) return;
    _offShelfDialogShown = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF2A2A2C),
          title: const Text('提示',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          content: const Text('该直播间已下播',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () async {
                Get.back();
                _offShelfDialogShown = false;
                if (Get.isRegistered<LiveFeedPageController>()) {
                  await Get.find<LiveFeedPageController>().refresh();
                }
                // 主播可能已重新开播:refresh 后按 roomId 重新定位弹幕控制器并强制重连,
                // 规避旧连接假死 / 重连次数耗尽导致 socket 收不到消息。
                final tag = 'danmu_$roomId';
                if (Get.isRegistered<DanmuController>(tag: tag)) {
                  await Get.find<DanmuController>(tag: tag).reconnect();
                } else {
                  Get.put(DanmuController(roomId: roomId), tag: tag);
                }
              },
              child: const Text('确定',
                  style: TextStyle(color: Color(0xFFFF4D6D))),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 强制重建弹幕 WS 连接。
  /// 用于"主播下播→重新开播→用户点击弹框确认"等场景:旧连接可能已被服务端断开
  /// 且重连次数耗尽,或处于 connected==true 的假死态,普通 connect() 会被幂等保护
  /// 拦截,必须强制重连才能恢复消息接收。
  Future<void> reconnect() async {
    _offShelfDialogShown = false;
    await connect(force: true);
  }

  /// 释放底层 WS 资源(不改变 _manualClose 语义),供 disconnect 与强制重连复用
  Future<void> _closeChannel() async {
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    connected.value = false;
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
    _closeChannel();
    // 清空顶部弹幕队列与当前展示
    _bannerQueue.clear();
    topBanner.value = null;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}