import 'package:get/get.dart';
import 'package:peiboshow/global_contoller/global_controller.dart';

import '../../api_request/api_request.dart';
import '../../api_request/api_request_client.dart';
import '../../models/live_room_model.dart';

class LiveFeedPageController extends GetxController {
  GlobalController globalController = Get.find<GlobalController>();
  List<LiveRoomModel>? rooms = [];

  /// 当前页码(从 1 开始)
  int _page = 1;

  /// 每页条数
  static const int _pageSize = 20;

  /// 服务端返回的总条数
  int total = 0;

  /// 是否正在请求,防止重复触发
  bool _loading = false;

  /// 是否还有下一页
  bool get hasMore => (rooms?.length ?? 0) < total;

  @override
  void onInit() {
    super.onInit();
    refresh();
  }

  /// 首次加载 / 下拉刷新: 回到第一页并覆盖数据
  Future<void> refresh() async {
    _page = 1;
    total = 0;
    await _fetchRooms(replace: true);
  }

  /// 上拉加载更多: 追加下一页
  Future<void> loadMore() async {
    if (!hasMore || _loading) return;
    await _fetchRooms(replace: false);
  }

  /// 请求并解析分页数据
  /// [replace] true=覆盖(刷新), false=追加(加载更多)
  Future<void> _fetchRooms({required bool replace}) async {
    if (_loading) return;
    _loading = true;
    try {
      await request(() async {
        final Map<String, dynamic> data = await requestClient.post(
          "/c-zhibo-room/pageList",
          data: {
            "page": _page,
            "size": _pageSize,
            "companyId": globalController.userModel?.companyId ?? "",
          },
        );

        // data = { "list": [...], "total": n }
        final List list = (data['list'] as List?) ?? [];
        total = (data['total'] as int?) ?? 0;

        final newRooms = list
            .map((e) =>
                LiveRoomModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        rooms = replace ? newRooms : [...?rooms, ...newRooms];
        // 本次成功才推进页码,失败时保持当前页以便重试
        _page++;
        update(["live_feed_page"]);
      });
    } finally {
      _loading = false;
    }
  }
}