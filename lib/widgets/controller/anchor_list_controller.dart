import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:peiboshow/api_request/api_request.dart';
import 'package:peiboshow/models/anchor_list_model.dart';

import '../../api_request/api_request_client.dart';

class AnchorListController extends GetxController {
  List<AnchorListModel>? anchorListModel;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getAnchorList();
  }

  Future<void> getAnchorList() async{
    request(()async{
      Map<String, dynamic> response = await requestClient.post("/wx-zhibo-room-item/pageListAvailable",data: {"page":1,"size":999,"online":true,"roomId":694});
      // 直接拿 list，它是 List<dynamic>
      List<dynamic> list = response["list"];
      anchorListModel = List<AnchorListModel>.from(list.map((x) => AnchorListModel.fromJson(x))).toList();
      print(response);
    });
  }

}