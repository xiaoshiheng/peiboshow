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

  @override
  void onInit() {
    super.onInit();
    getAnchorList();
  }

  /// 请求主播列表(每次进入面板都会新建控制器并调用)
  Future<bool> getAnchorList() async {
    loading.value = true;
    final bool ok = await request(() async {
      final Map<String, dynamic> response = await requestClient.post(
        '/wx-zhibo-room-item/pageListAvailable',
        data: {
          'page': 1,
          'size': 999,
          'online': true,
          'roomId': roomId,
        },
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

  /// 移出直播间
  Future<bool> removeAnchor(AnchorListModel item) async {
    // TODO: 接入"移出直播间"接口,示例:
    // return await request(() async {
    //   await requestClient.post('/wx-zhibo-room-item/leave',
    //       data: {'roomId': roomId, 'itemId': item.itemId});
    // });
    return false;
  }
}