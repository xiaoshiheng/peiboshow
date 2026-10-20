import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:peiboshow/models/recommend_model.dart';

import '../../api_request/api_request.dart';
import '../../api_request/api_request_client.dart';
import '../../global_contoller/global_controller.dart';
import '../../models/add_anchor_model.dart';
import '../../models/level_model.dart';

class AddAnchorController extends GetxController {
  AddAnchorController({required this.roomId});

  final int roomId;

  GlobalController globalController = Get.find<GlobalController>();

  /// 加载状态(仅主播列表请求维护,筛选请求不干扰)
  final RxBool loading = true.obs;

  /// 响应式列表:赋值即触发 Obx 重建,避免依赖 loading 变化刷新
  final RxList<AddAnchorModel> anchorList = <AddAnchorModel>[].obs;

  final RxList<LevelModel> levelList = <LevelModel>[].obs;

  final RxList<RecommendModel> recommendList = <RecommendModel>[].obs;

  /// 请求主播列表(每次进入面板都会新建控制器并调用)
  Future<bool> getAnchorList() async {
    loading.value = true;
    final bool ok = await request(() async {
      final Map<String, dynamic> data = {
        'page': 1,
        'size': 999,
        'search': "",
        'zhibo': false,
        'status':"item_up_shelves",
        "process":"on_sale"
      };
      final Map<String, dynamic> response = await requestClient.post(
        '/wx-item/pageList',
        data: data,
      );
      print(response);
      anchorList.assignAll((response['list'] as List)
          .map((e) => AddAnchorModel.fromJson(e))
          .toList());
    }, showLoading: false);
    loading.value = false;
    return ok;
  }

  /// 添加主播
  Future<bool> addAnchor(List<int> ids) async {
    loading.value = true;
    final bool ok = await request(() async {
      final Map<String, dynamic> data = {
        'ids': ids,
        'roomId': roomId,
      };
      final dynamic response = await requestClient.post(
        '/wx-zhibo-room-item/joinBatch',
        data: data,
      );
      print(response);
    }, showLoading: true);
    loading.value = false;
    return ok;
  }

  ///获取推荐人(筛选数据源,失败不影响主播列表;注意:该接口为 POST,参数走 body)
  Future<bool> getRecommend() async {
    final bool ok = await request(() async {
      final Map<String, dynamic> data = {
        'companyId': globalController.userModel?.companyId ?? "",
      };
      final Map<String, dynamic> response = await requestClient.post(
        '/wx-item/big-leader-list',
        data: data,
      );
      print(response);
      // 返回结构为 data: {list: [...]},requestClient 已解包外层 data,直接取 list 解析
      recommendList.assignAll(((response['list'] as List?) ?? const [])
          .map((e) => RecommendModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList());
    }, showLoading: false);
    return ok;
  }

  ///获取段位(筛选数据源,失败不影响主播列表)
  Future<bool> getLevel() async {
    final bool ok = await request(() async {
      final Map<String, dynamic> response = await requestClient.post(
        '/c-tag/danlist',
      );
      print(response);
      // danlist 返回的 list 是嵌套数组(按 type 分组),递归摊平后解析
      final List<LevelModel> result = <LevelModel>[];
      void flatten(List items) {
        for (final dynamic e in items) {
          if (e is List) {
            flatten(e);
          } else if (e is Map) {
            result.add(LevelModel.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      }
      flatten((response['list'] as List?) ?? const []);
      levelList.assignAll(result);
    }, showLoading: false);
    return ok;
  }
}