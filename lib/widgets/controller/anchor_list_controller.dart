import 'package:get/get.dart';
import 'package:peiboshow/models/confirmed_anchor_model.dart';

import '../../api_request/api_request.dart';
import '../../api_request/api_request_client.dart';
import '../../models/anchor_list_model.dart';

class AnchorListController extends GetxController {
  AnchorListController({required this.roomId, this.autoLoad = true});

  final int roomId;

  /// 是否在 onInit 自动请求主播列表(已确认主播面板传 false)
  final bool autoLoad;

  /// 主播列表
  final RxList<AnchorListModel> anchors = <AnchorListModel>[].obs;

  /// 已确认主播列表
  final RxList<ConfirmedAnchorModel> confirmedAnchors = <ConfirmedAnchorModel>[].obs;


  /// 已确认主播加载状态
  final RxBool confirmedLoading = false.obs;

  /// 加载状态
  final RxBool loading = true.obs;

  /// 一见倾心筛选状态: null=全部, 1=已一见倾心, 0=未一见倾心
  final Rxn<int> likeFilter = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    if (autoLoad) getAnchorList();
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
        'orderByPreTimeDesc': true,
      };
      // 全部状态不传 tempOrder,已/未一见倾心分别传 true/false
      final int? like = likeFilter.value;
      if (like != null) {
        data['tempOrder'] = like == 1;
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
            'setAppoint':true,
          });
    });
  }

///立即前往
  Future<bool> likeAnchor(AnchorListModel item) async {
    return await request(() async {
      await requestClient.post('/wx-zhibo-room-item/addOrder',
          data: {'id': item.id});
    });
  }

  ///已确认主播:返回数据格式与 getAnchorList 一致
  Future<bool> confirmAnchor() async {
    confirmedLoading.value = true;
    final bool ok = await request(() async {
      final Map<String, dynamic> response = await requestClient.post(
        '/wx-zhibo-room-item/itemListByRoomAndOrder',
        data: {'roomId': roomId},
      );
      final List list = (response['list'] as List?) ?? [];
      confirmedAnchors.assignAll(list
          .map((x) =>
          ConfirmedAnchorModel.fromJson(Map<String, dynamic>.from(x as Map)))
          .toList());
    }, showLoading: false);
    confirmedLoading.value = false;
    return ok;
  }
}