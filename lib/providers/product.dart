import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  //Изменение статуса любимых продуктов
  Future<void> toggleFavoriteStatus(String? authToken, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/userFavorites/$userId/products/$id.json?auth=$authToken');
    try {
      // Отправляем на сервер новое значение
      final responce = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      // Если неверный статус ответа с сервера - возвращаем старое значение
      if (responce.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
