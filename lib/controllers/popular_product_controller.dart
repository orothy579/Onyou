import 'package:get/get.dart';
import 'package:onebody/controllers/cart_controller.dart';
import 'package:onebody/data/repository/popular_product_repo.dart';

import '../model/cart_model.dart';
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
      print("number of items " + _quantity.toString());
    }else{
      _quantity = checkQuantity(quantity-1);
      //print("decrement " + _quantity.toString());
    }
    update();
  }

  int checkQuantity(int quantity){
    if((_inCartItems+quantity)<0){
      Get.snackbar("ð", "더 적게 담을 수 없어요!");
      if(_inCartItems>0){
        _quantity = -_inCartItems;
        return _quantity;
      }
      return 0;
    } else if((_inCartItems+quantity)>100){
      Get.snackbar("Item count", "더 많이 담을 수 없어요!");
      return 100; //maximum quantity
    } else {
      return quantity;
    }
  }

  void initProduct(ProductsModel product, CartController cart){
    _quantity = 0;
    _inCartItems = 0;
    _cart = cart;
    var exist =false;
    exist = _cart.existInCart(product);

    print("exist or not "+ exist.toString());
    if(exist){
      _inCartItems = _cart.getQuantity(product);
    }
    print("the quantity in the cart is " + _inCartItems.toString());

  }

  void addItem(ProductsModel product){

      _cart.addItem(product, _quantity);

      _quantity=0;
      _inCartItems = _cart.getQuantity(product);

      _cart.items.forEach((key, value) {
        print("The id is "+ value.id.toString() + " The quantity is " + value.quantity.toString());
      });

      update();

  }

  int get totalItems{
    return _cart.totalItems;
  }

  List<CartModel> get getItems{
    return _cart.getItems;
  }

}