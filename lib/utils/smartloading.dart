import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

int _loadingCount = 0;//加引用计数机制，方式前一个请求完成后，把后一个请求的loading消失掉

Future loading( Function block, {bool isShowLoading = true}) async{
  if (isShowLoading) {
    showLoading();
  }
  try {
    await block();
  } catch (e) {
    rethrow;
  } finally {
    if (isShowLoading) {
      dismissLoading();
    }
  }
  return;
}


void showLoading(){
  _loadingCount++;
  SmartDialog.showLoading(msg: "加载中...");
}

void dismissLoading(){
  _loadingCount--;
  if (_loadingCount <= 0) {
    _loadingCount = 0;
    SmartDialog.dismiss(status: SmartStatus.loading);
  }
}