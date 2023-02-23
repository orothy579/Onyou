import 'package:get/get.dart';

import '../../utils/app_constant.dart';
import '../api/api_client.dart';

class PopularProductRepo extends GetxService {
  final ApiClient apiClient;
  PopularProductRepo({required this.apiClient});

  Future<Response> getPopularProductList() async{
    return await apiClient.getData(AppConstants.POPULAR_PRODUCT_URI); //part 1 5:35:04 --> 이 링크 주소 좀 나중에 바꿔야 할 듯
  }

}