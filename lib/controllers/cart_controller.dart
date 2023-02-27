import 'dart:io';

import 'package:get/get.dart';
import 'package:onebody/model/products.dart';
import '../data/repository/cart_repo.dart';
import '../model/cart_model.dart';

class CartController extends GetxController{
  final CartRepo cartRepo;
  CartController({required this.cartRepo});
  Map<int, CartModel> _items = {};

  Map<int, CartModel> get items => _items;

  void addItem(ProductsModel product, int quantity){
    var totalQuantity = 0;

    if(_items.containsKey(product.id!)){
      _items.update(product.id!, (value) {

        totalQuantity = value.quantity!+quantity;


        return CartModel(
          id: value.id,
          name : value.name,
          price : value.price,
          img : value.img,
          quantity : value.quantity! + quantity,
          isExist : true,
          time : DateTime.now().toString(),
        );
      });

      if(totalQuantity <=0){
        _items.remove(product.id);
      }

    }else{
      if(quantity>0){
        _items.putIfAbsent(product.id!, ()
        {
          return CartModel(
            id: product.id,
            name : product.name,
            price : product.price,
            img : product.img,
            quantity : quantity,
            isExist : true,
            time : DateTime.now().toString(),
          );});
      } else{
        Get.snackbar("Item count", "하나 이상은 카트에 넣어야 해요.");
      }

    }
    // print("length of the item is " + _items.length.toString());

  }

  bool existInCart(ProductsModel product){
    if(_items.containsKey(product.id)){
      return true;
    }
    return false;
  }

  int getQuantity(ProductsModel product){
    var quantity = 0;
    if(_items.containsKey(product.id)){
      _items.forEach((key, value) {
        if(key == product.id){
          quantity = value.quantity!;
        }
      });
    }
    return quantity;
  }

  int get totalItems{
    var totalQuantity = 0;
    _items.forEach((key, value) {
      totalQuantity += value.quantity!;
    });
    return totalQuantity;
  }
  
  List<CartModel> get getItems{
    return _items.entries.map((e) {
      return e.value;
    }).toList();
  }

}

