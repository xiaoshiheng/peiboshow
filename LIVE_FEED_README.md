# 网易云信直播流滑动切换 - peiboshow

本项目已集成完整的直播间垂直滑动切换功能,支持RTMP/HLS/FLV协议。

## 📦 项目结构

```
lib/
├── main.dart                          # 应用入口
├── models/
│   └── live_room_model.dart          # 直播间数据模型
├── services/
│   └── netease_live_service.dart     # 网易云信服务(含模拟数据)
├── widgets/
│   └── live_stream_player.dart       # 直播流播放器(VLC)
└── pages/
    └── live_feed_page.dart           # 直播Feed页面(垂直滑动)
```

## 🚀 运行项目

### 1. 确保依赖已安装

```bash
flutter pub get
```

### 2. 运行项目

```bash
# iOS模拟器
flutter run -d ios

# Android模拟器
flutter run -d android

# 真机调试
flutter run
```

### 3. 热重载

运行后修改代码,按 `r` 键热重载查看效果。

## 🎯 功能特性

### ✅ 已实现
- **垂直滑动切换**: PageView实现原生60fps流畅滑动
- **多协议支持**: RTMP / HLS / FLV 直播流
- **自动播放控制**: 当前直播间自动播放,其他暂停
- **UI覆盖层**: LIVE标识、在线人数、主播信息、标签
- **双击点赞**: 爱心动画反馈
- **加载状态**: 缓冲指示器、错误提示

### 📱 界面说明

1. **首页**: 点击"进入直播广场"按钮
2. **Feed页**: 上下滑动切换直播间
3. **顶部**: 显示当前进度 (1/5)
4. **右侧**: 点赞、弹幕、分享按钮
5. **底部**: 主播信息和房间标题

## 🔧 配置真实数据

当前使用模拟数据,实际使用时需要:

### 方式一: 修改模拟数据

编辑 `lib/services/netease_live_service.dart`:

```dart
LiveRoomModel(
  roomId: 'your_room_id',
  streamUrl: 'https://your-real-stream-url.m3u8', // 替换为真实地址
  // ...
)
```

### 方式二: 调用网易云信API

参考文件中的注释示例,实现真实的API调用。

## ⚙️ VLC播放器配置

直播流延迟优化参数在 `lib/widgets/live_stream_player.dart`:

```dart
options: [
  '--network-caching=1000',  // 缓存1秒(可调整)
  '--live-caching=1000',
  '--clock-jitter=0',
  '--clock-synchro=0',
]
```

**降低延迟**: 减小缓存时间(如500ms),但可能增加卡顿
**提高稳定性**: 增大缓存时间(如2000ms),但延迟增加

## 🐛 常见问题

### Q: 视频无法加载?
A: 
1. 检查拉流地址是否正确
2. 确认网络连接正常
3. 查看控制台错误日志
4. 尝试切换到其他协议(HLS兼容性最好)

### Q: 滑动卡顿?
A:
1. 确保及时pause非活跃流(已实现)
2. 降低视频分辨率
3. 检查设备性能

### Q: 如何在真机上测试?
A:
1. iOS: 需要Apple Developer账号
2. Android: 开启USB调试,连接手机即可

## 📊 测试建议

由于使用的是模拟拉流地址,实际播放会失败。建议:

1. **先测试UI交互**: 滑动、点击等功能正常
2. **替换为真实地址**: 从网易云信控制台获取测试拉流地址
3. **完整测试**: 验证播放、切换、暂停等功能

## 🎨 自定义UI

所有UI组件都在 `lib/widgets/live_stream_player.dart`,可以自由修改:
- 按钮样式和位置
- 文字大小和颜色
- 渐变遮罩效果
- 添加新元素(如弹幕、礼物等)

---

**提示**: 这是一个完整可运行的项目框架,直接替换拉流地址即可用于生产环境。
