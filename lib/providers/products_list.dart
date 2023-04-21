// Работа с товарами в заказе

import 'package:flutter/material.dart';

class ProductListItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  ProductListItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class ProductsList with ChangeNotifier {
  // Список товаров в заказе
  Map<String, ProductListItem> _items = {};

  // Получение всех позиций корзины
  Map<String, ProductListItem> get items {
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
        (existingCartItem) => ProductListItem(
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
        () => ProductListItem(
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
    String _ids = '';
    _items.forEach(
      (key, value) {
        if (value.id == productId) {
          _ids = key;
        }
      },
    );
    _items.remove(_ids);
    notifyListeners();
  }

  // Очистка позиций в заказе
  void clear() {
    _items = {};
    //   notifyListeners();
  }
}
