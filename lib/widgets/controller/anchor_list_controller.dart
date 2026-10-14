import 'package:get/get.dart';

import '../../api_request/api_request.dart';
import '../../api_request/api_request_client.dart';
import '../../models/anchor_list_model.dart';

class AnchorListController extends GetxController {
  AnchorListController({required this.roomId});

  final int roomId;

  /// 主播列表
  final RxList<AnchorListModel> anchors = <AnchorListModel>[].obs;

  /// 加载状态
  final RxBool loading = true.obs;

  /// 一见倾心筛选状态: null=全部, 1=已一见倾心, 0=未一见倾心
  final Rxn<int> likeFilter = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    getAnchorList();
  }

  /// 请求主播列表(每次进入面板都会新建控制器并调用)
  Future<bool> getAnchorList() async {
    loading.value = true;
    final bool ok = await request(() async {
      final Map<String, dynamic> data = {
        'page': 1,
        'size': 999,
        'online': true,
        'roomId': roomId,
      };
      // 全部状态不传 isLike,已/未一见倾心分别传 1/0
      final int? like = likeFilter.value;
      if (like != null) {
        data['isLike'] = like;
      }
      final Map<String, dynamic> response = await requestClient.post(
        '/wx-zhibo-room-item/pageListAvailable',
        data: data,
      );
      final List list = (response['list'] as List?) ?? [];
      anchors.assignAll(list
          .map((x) =>
          AnchorListModel.fromJson(Map<String, dynamic>.from(x as Map)))
          .toList());
    }, showLoading: false);
    loading.value = false;
    return ok;
  }

  /// 切换一见倾心筛选并重新请求
  Future<bool> setLikeFilter(int? like) async {
    if (likeFilter.value == like) return true;
    likeFilter.value = like;
    return getAnchorList();
  }

  /// 移出直播间
  Future<bool> removeAnchor(AnchorListModel item) async {
    return await request(() async {
      await requestClient.post('/wx-zhibo-room-item/batchLeaveItem',
          data: {
            'roomId': roomId,
            'ids': [item.sitem?.id ?? 0],
          });
    });
  }
}