import 'package:get/get.dart';
import 'package:onebody/controllers/cart_controller.dart';
import 'package:onebody/data/repository/popular_product_repo.dart';

import '../model/products.dart';

class PopularProductController extends GetxController{
  final PopularProductRepo popularProductRepo;
  PopularProductController({required this.popularProductRepo});
  List<dynamic> _popularProductList=[];
  List<dynamic> get popularProductList => _popularProductList;
  late CartController _cart;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  int _quantity = 0;
  int get quantity => _quantity;
  int _inCartItems =0;
  int get inCartItems => _inCartItems + _quantity;

  Future<void> getPopularProductList() async{
    Response response = await popularProductRepo.getPopularProductList();
    if(response.statusCode ==200){
      _popularProductList=[];
      _popularProductList.addAll(Product.fromJson(response.body).products);
      _isLoaded = true;
      update();
    }else{

    }
  }

  void setQuantity(bool isIncrement) {
    if(isIncrement){
      _quantity = checkQuantity(quantity+1);
    }else{
      _quantity = checkQuantity(quantity-1);
    }
    update();
  }
  int checkQuantity(int quantity){
    if(quantity<0){
      Get.snackbar("Item count", "더 적게 담을 수 없어요!");
      return 0;
    } else if(quantity>100){
      Get.snackbar("Item count", "더 많이 담을 수 없어요!");
      return 100; //maximum quantity
    } else {
      return quantity;
    }
  }

  void initProduct(CartController cart){
    _quantity = 0;
    _inCartItems = 0;
    _cart = cart;

    //if exist
    //get from storage _inCartitems = 3
  }

  void addItem(ProductsModel product){
    if(_quantity >0){
      _cart.addItem(product, _quantity);
      _quantity=0;
      _cart.items.forEach((key, value) {
        print("The id is "+ value.id.toString() + "The quantity is" + value.quantity.toString());
      });
    }else{
      Get.snackbar("Item count", "하나 이상은 카트에 넣어야 해요.");
    }
  }

}