// Работа с продуктами

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  String authToken = '';
  String userId = '';

  Products(this.authToken, this.userId, this._items);

  // Получение всех продуктов
  List<Product> get items {
    return [..._items];
  }

  // Получение любимых продуктов
  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  // Поиск продукта по id
  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // Загрузка списка продуктов с сервера в переменную _items в памяти
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      if (response.body.length <= 4) {
        return;
      }
      url = Uri.parse(
          'https://puellaveris-70849-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResonse = await http.get(url);
      final favoriteData = json.decode(favoriteResonse.body);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Добавление продукта
  Future<void> addProduct(Product product) async {
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      // Отправляем данные о новом продукте на сервер, получает id продукта в response.body ['name']
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      // Создаем локально новый продукт и добавляем в список продуктов _items в памяти
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Обновление продукта
  Future<void> updateProduct(String id, Product newProduct) async {
    // Ищем индекс обновляемого продукта
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      Uri url = Uri.parse(
          'https://puellaveris-70849-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      // Обновляем поля продукта с идентификатором id на сервере
      await http.patch(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          },
        ),
      );
      // Обновляем продукт в списке продуктов _items в памяти
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  // Удаление продукта по id
  Future<void> deleteProduct(String id) async {
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    // Сохраняем удаляемый продукт в existingProduct
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    // Удаляем продукт из списка продуктов _items в памяти
    _items.removeAt(existingProductIndex);
    notifyListeners();
    // Удаляем продукт из списка продуктов на сервере и сохраняем ответ с сервера
    final response = await http.delete(url);
    // Если получаем ошибку с сервера - добавляем обратно наш "удаляемый" продукт на его место
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
