// Работа с корзиной

import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  // Список товаров в корзине
  Map<String, CartItem> _items = {};

  // Получение всех позиций корзины
  Map<String, CartItem> get items {
    return {..._items};
  }

  // Получение количества позиций в корзине
  int get itemCount {
    return _items.length;
  }

  // Получение суммы товаров в корзине
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Добавлении позиции в корзину
  void addItem(
    String productId,
    double price,
    String title,
  ) {
    // Если такая позиция уже есть - увеличиваем количество на 1
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
        ),
      );
      // Иначе добавляем новую позицию
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners(); //обновляем инфу у слушателей
  }

  // Удаляем позицию из корзины
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Отмена только что добавленной позиции
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if ((_items[productId]?.quantity ?? 0) > 1) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              quantity: existingCartItem.quantity - 1,
              price: existingCartItem.price));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Очистка корзины
  void clear() {
    _items = {};
    notifyListeners();
  }
}
