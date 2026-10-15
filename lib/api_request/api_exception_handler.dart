import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../routes/all_routes.dart';
import '../utils/nsuserdefault.dart';
import 'api_exception.dart';

bool handleException(ApiException exception, {bool Function(ApiException)? onError, bool isShowLoading = false}){

  if(onError?.call(exception) == true){
    return true;
  }

  //登录失效，请重新登录
  if(exception.code == 10003 ){
    removeToken();
    return true;
  }
  if(isShowLoading){
    if(exception.code == 10001){
      SmartDialog.showNotify(msg: exception.message ?? ApiException.unknownException, notifyType: NotifyType.success);
      return true;
    }
    // SmartDialog.showNotify(msg: exception.message ?? ApiException.unknownException, notifyType: NotifyType.error);
    SmartDialog.showToast( exception.message ?? ApiException.unknownException);
  }else{
    SmartDialog.showToast( exception.message ?? ApiException.unknownException);
  }


  return false;
}

void removeToken() async {
  NSUserDefault userDefault = await NSUserDefault.getInstance();
  await userDefault.removeValueForKey("token");
  
  // 直接跳转到登录页，清空路由栈
  Get.offAllNamed(AllRoutes.login);
}