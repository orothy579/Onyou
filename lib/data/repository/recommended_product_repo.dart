import 'package:get/get.dart';

import '../../utils/app_constant.dart';
import '../api/api_client.dart';

class RecommendedProductRepo extends GetxService {
  final ApiClient apiClient;
  RecommendedProductRepo({required this.apiClient});

  Future<Response> getRecommendedProductList() async{
    return await apiClient.getData(AppConstants.RECOMMENDED_PRODUCT_URI); //part 1 5:35:04 --> 이 링크 주소 좀 나중에 바꿔야 할 듯
  }
}