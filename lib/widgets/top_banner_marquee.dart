import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/controller/danmu_controller.dart';

/// 直播间顶部滚动弹幕(类型4):红色跑马灯,一次只滚动一条,多条由控制器排队
class TopBannerMarquee extends StatefulWidget {
  /// 对应 DanmuController 的 GetX tag
  final String tag;

  const TopBannerMarquee({super.key, required this.tag});

  @override
  State<TopBannerMarquee> createState() => _TopBannerMarqueeState();
}

class _TopBannerMarqueeState extends State<TopBannerMarquee>
    with SingleTickerProviderStateMixin {
  late final DanmuController _controller =
  Get.find<DanmuController>(tag: widget.tag);
  late final AnimationController _anim = AnimationController(vsync: this);

  /// 红色字体样式
  static const TextStyle _style = TextStyle(
    color: Colors.red,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
  );

  /// 滚动速度(像素/秒)
  static const double _speed = 80;

  /// 当前正在滚动的文本,用于判断是否需要重新起动画
  String? _current;

  @override
  void initState() {
    super.initState();
    _anim.addStatusListener((status) {
      // 滚动结束:通知控制器展示下一条(排队中的)
      if (status == AnimationStatus.completed) {
        _controller.onTopBannerFinished();
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  /// 测量文本宽度,用于计算滚动距离
  double _measure(String text) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: _style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String? text = _controller.topBanner.value;
      if (text == null || text.isEmpty) {
        _current = null;
        return const SizedBox.shrink();
      }
      return LayoutBuilder(builder: (context, cons) {
        final double containerWidth = cons.maxWidth;
        final double textWidth = _measure(text);

        // 文本变化时才重新启动动画(队列保证一次只有一条)
        if (text != _current) {
          _current = text;
          final double distance = containerWidth + textWidth;
          final int ms =
          (distance / _speed * 1000).clamp(3000, 20000).toInt();
          _anim.duration = Duration(milliseconds: ms);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _anim.forward(from: 0);
          });
        }

        return ClipRect(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, child) {
              final double startX = containerWidth;
              final double endX = -textWidth;
              final double x = startX + (endX - startX) * _anim.value;
              return Stack(
                children: [
                  Positioned(left: x, top: 0, bottom: 0, child: child!),
                ],
              );
            },
            child: Text(text, style: _style, maxLines: 1, softWrap: false),
          ),
        );
      });
    });
  }
}