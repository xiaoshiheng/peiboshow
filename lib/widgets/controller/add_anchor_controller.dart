import 'package:get/get.dart';
import 'package:meta/meta.dart';

import '../../api_request/api_request.dart';
import '../../api_request/api_request_client.dart';
import '../../models/add_anchor_model.dart';

class AddAnchorController extends GetxController {
  AddAnchorController({required this.roomId});

  final int roomId;
  /// 加载状态
  final RxBool loading = true.obs;

  List<AddAnchorModel> anchorList = <AddAnchorModel>[];

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
      anchorList = (response['list'] as List)
          .map((e) => AddAnchorModel.fromJson(e))
          .toList();
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
      final Map<String, dynamic> response = await requestClient.post(
        '/wx-zhibo-room-item/joinBatch',
        data: data,
      );
      print(response);
    }, showLoading: false);
    loading.value = false;
    return ok;
  }
}