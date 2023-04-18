import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class Products with ChangeNotifier {
  // Список продукции
  List<ProductItem> _products = [];

  // Токен авторизации и id пользователя
  String authToken = '';
  String userId = '';

  Products(this.authToken, this.userId, this._products);

  // Получение списка всей продуктции
  List<ProductItem> get products {
    return [..._products];
  }

  // Получение количества продукции
  int get productsCount {
    return _products.length;
  }

  // Поиск продукции по id
  ProductItem findById(String id) {
    return _products.firstWhere((item) => item.id == id);
  }

  // Загрузка списка продукции с сервера в переменную _products в памяти
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/production.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      if (response.body.length <= 4) {
        return;
      }
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<ProductItem> loadedClients = [];
      extractedData.forEach((prodId, prodData) {
        loadedClients.add(
          ProductItem(
            id: prodId,
            title: prodData['title'],
            price: prodData['price'],
            cost: prodData['cost'],
            isWeight: prodData['isWeight'],
          ),
        );
      });
      _products = loadedClients;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Добавление нового продукта
  Future<void> addProductr(ProductItem product) async {
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/production.json?auth=$authToken');
    try {
      // Отправляем данные о новом продукте на сервер, получает id продукта в response.body ['name']
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'price': product.price,
          'cost': product.cost,
          'isWeight': product.isWeight,
        }),
      );
      // Создаем локально новый продукт и добавляем в список продуктов _items в памяти
      final newProduct = ProductItem(
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        cost: product.cost,
        isWeight: product.isWeight,
      );
      _products.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Обновление продукта
  Future<void> updateProduct(String id, ProductItem newProduct) async {
    // Ищем индекс обновляемого продукта
    final prodIndex = _products.indexWhere((prod) => prod.id == id);
    try {
      if (prodIndex >= 0) {
        Uri url = Uri.parse(
            'https://puellaveris-70849-default-rtdb.firebaseio.com/production/$id.json?auth=$authToken');
        await http.patch(
          url,
          body: json.encode(
            {
              'title': newProduct.title,
              'price': newProduct.price,
              'cost': newProduct.cost,
              'isWeight': newProduct.isWeight,
            },
          ),
        );
        // Обновляем продукт в списке продуктов
        _products[prodIndex] = newProduct;
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  // Удаление продукта по id
  Future<void> deleteProduct(String id) async {
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/production/$id.json?auth=$authToken');
    // Сохраняем удаляемый продукт в existingProduct
    final existingProductIndex = _products.indexWhere((prod) => prod.id == id);
    ProductItem? existingProduct = _products[existingProductIndex];
    // Удаляем продукт из списка продуктов _products в памяти
    _products.removeAt(existingProductIndex);
    notifyListeners();
    // Удаляем продукт из списка продуктов на сервере и сохраняем ответ с сервера
    final response = await http.delete(url);
    // Если получаем ошибку с сервера - добавляем обратно наш "удаляемый" продукт на его место
    if (response.statusCode >= 400) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw const HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
