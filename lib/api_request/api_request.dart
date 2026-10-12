import '../utils/smartloading.dart';
import 'api_exception.dart';
import 'api_exception_handler.dart';

Future<bool> request(Function() block,  {bool showLoading = true, bool Function(ApiException)? onError, }) async{
  try {
    await loading(block, isShowLoading:  showLoading);
    return true;
  } catch (e) {
    handleException(ApiException.from(e), onError: onError,isShowLoading: showLoading);
  }
  return false;
}