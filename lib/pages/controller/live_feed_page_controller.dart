import 'package:get/get.dart';
import 'package:meta/meta.dart';

import '../../api_request/api_request.dart';
import '../../api_request/api_request_client.dart';
import '../../models/live_room_model.dart';

class LiveFeedPageController extends GetxController {
  List<LiveRoomModel>? rooms;


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    // /c-zhibo-room/pageList
    request(()async{
      Map<String, dynamic> data = await requestClient.post("/c-zhibo-room/pageList",data: {"page":1,"size":20,"companyId":10001});
      print(data);
      update();
    });
  }
}