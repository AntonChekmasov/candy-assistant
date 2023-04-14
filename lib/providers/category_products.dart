import 'package:flutter/material.dart';

class ProductItem {
  final String id; // id продукта
  final String title; // название товара
  final bool isWeight; // true - весовой товар, false - штучный
  final double price; // цена товара
  final double cost; // себестоимость товара
//  final int amount; // количество

  ProductItem({
    required this.id,
    required this.title,
    required this.isWeight,
    required this.price,
    required this.cost,
//    required this.amount,
  });
}

class CatProducts with ChangeNotifier {
  List<ProductItem> _products = [
    ProductItem(
      id: '1',
      title: 'Торт Медовик',
      isWeight: true,
      price: 2000,
      cost: 1200,
    ),
    ProductItem(
      id: '2',
      title: 'Торт Манго-личи',
      isWeight: true,
      price: 2200,
      cost: 1300,
    ),
    ProductItem(
      id: '3',
      title: 'Капкейки Шоколад',
      isWeight: false,
      price: 200,
      cost: 100,
    ),
  ];

  // Получение списка всех продуктов
  List<ProductItem> get products {
    return [..._products];
  }

  // Получение количества клиентов
  int get productsCount {
    return _products.length;
  }

  // Поиск клиента по id
  ProductItem findById(String id) {
    return _products.firstWhere((item) => item.id == id);
  }

  // Добавление нового продукта
  void addProductr(ProductItem product) {
    final newProduct = ProductItem(
      id: 'id',
      title: product.title,
      isWeight: product.isWeight,
      price: product.price,
      cost: product.cost,
    );
    _products.add(newProduct);
    notifyListeners();
  }

  // Обновление продукта
  void updateProduct(String id, ProductItem newProduct) {
    // Ищем индекс обновляемого продукта
    final prodIndex = _products.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      // Обновляем продукт в списке продуктов
      _products[prodIndex] = newProduct;
      notifyListeners();
    }
  }
}
