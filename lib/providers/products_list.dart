// Работа с товарами в заказе

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  ProductItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class ProductsList with ChangeNotifier {
  // Список товаров в заказе
  Map<String, ProductItem> _items = {};

  // Получение всех позиций корзины
  Map<String, ProductItem> get items {
    return {..._items};
  }

  // Получение количества позиций в заказе
  int get itemCount {
    return _items.length;
  }

  // Получение суммы товаров в заказе
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Добавлении позиции в заказ
  void addItem(
    String productId,
    double price,
    String title,
    int quantity,
    bool? isUpdate,
  ) {
    // Если такая позиция уже есть - изменяем количество
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => ProductItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: quantity,
          price: existingCartItem.price,
        ),
      );
      // Иначе добавляем новую позицию
    } else {
      _items.putIfAbsent(
        productId,
        () => ProductItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: quantity,
        ),
      );
    }
    if (isUpdate == true) {
      notifyListeners();
    }
  }

  // Удаляем позицию из заказа
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Очистка позиций в заказе
  void clear() {
    _items = {};
    //   notifyListeners();
  }
}
