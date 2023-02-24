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
    if(_items.containsKey(product.id!)){
      _items.update(product.id!, (value) {
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
    }else{
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
    }
    // print("length of the item is " + _items.length.toString());

  }
}

