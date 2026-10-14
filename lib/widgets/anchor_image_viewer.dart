import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 全屏大图查看器,支持多张滑动
class AnchorImageViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const AnchorImageViewer({
    super.key,
    required this.urls,
    this.initialIndex = 0,
  });

  /// 以透明路由打开大图查看器
  static Future<void> show(BuildContext context, List<String> urls,
      {int initialIndex = 0}) {
    if (urls.isEmpty) return Future.value();
    return Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) =>
          AnchorImageViewer(urls: urls, initialIndex: initialIndex),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ));
  }

  @override
  State<AnchorImageViewer> createState() => _AnchorImageViewerState();
}

class _AnchorImageViewerState extends State<AnchorImageViewer> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex.clamp(0, widget.urls.length - 1),
  );
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.urls.length - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.urls.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) => Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.urls[index],
                    fit: BoxFit.contain,
                    progressIndicatorBuilder: (_, __, ___) =>
                    const CircularProgressIndicator(color: Colors.white),
                    errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48),
                  ),
                ),
              ),
            ),
            if (widget.urls.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.urls.length}',
                      style:
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}