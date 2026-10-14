class RequestConfig{
  //static const baseUrl = "http://cash.peibosocial.cn";
  static const connectTimeout = 15000;
  static const successCode = [10000,10001];

  // ===== WebSocket 弹幕配置(需按后端调整) =====
  /// 弹幕 WS 路径,最终地址为 ws://{baseurl}{danmuWsPath}?roomId=xxx&token=xxx
  static const String danmuWsPath = "/c-zhibo-room/danmu/ws";
  /// 心跳间隔(秒)
  static const int danmuHeartbeatSeconds = 30;
}