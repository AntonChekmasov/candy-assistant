import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/products_list.dart';

class OrderItem {
  final String id;
  final String clientName;
  final List<ProductItem> products;
  final double summ;
  final double payed;
  final bool isDelivery;
  final String adress;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.clientName,
    required this.products,
    required this.summ,
    required this.payed,
    required this.isDelivery,
    required this.adress,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  // Токен авторизации и id пользователя
  String authToken = '';
  String userId = '';

  Orders(this.authToken, this.userId, this._orders);

  // Получение списка всех заказов
  List<OrderItem> get orders {
    return [..._orders];
  }

// Загрузка списка заказов с сервера в переменную _orders в памяти
  Future<void> fetchAndSetOrders([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/orders.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      if (response.body.length <= 4) {
        return;
      }
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((ordId, ordData) {
        loadedOrders.add(
          OrderItem(
            id: ordId,
            clientName: ordData['clientName'],
            products: (ordData['products'] as List<dynamic>)
                .map(
                  (item) => ProductItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ),
                )
                .toList(),
            summ: ordData['summ'],
            payed: ordData['payed'],
            isDelivery: ordData['isDelivery'],
            adress: ordData['adress'],
            dateTime: DateTime.parse(ordData['dateTime']),
          ),
        );
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Добавление нового заказа
  Future<void> addOrder(OrderItem order) async {
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/orders.json?auth=$authToken');
    try {
      // Отправляем данные о новом заказе на сервер, получает id заказа в response.body ['name']
      final response = await http.post(
        url,
        body: json.encode({
          'clientName': order.clientName,
          'products': order.products
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
          'summ': order.summ,
          'payed': order.payed,
          'isDelivery': order.isDelivery,
          'adress': order.adress,
          'dateTime': order.dateTime.toIso8601String(),
        }),
      );
      // Создаем локально новый заказ и добавляем в список заказов _orders в памяти
      final newOrder = OrderItem(
        id: json.decode(response.body)['name'],
        clientName: order.clientName,
        products: order.products,
        summ: order.summ,
        payed: order.payed,
        isDelivery: order.isDelivery,
        adress: order.adress,
        dateTime: order.dateTime,
      );
      _orders.add(newOrder);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Обновление заказа
  Future<void> updateOrder(String id, OrderItem order) async {
    // Ищем индекс обновляемого заказа
    final orderIndex = _orders.indexWhere((ord) => ord.id == id);
    try {
      if (orderIndex >= 0) {
        Uri url = Uri.parse(
            'https://puellaveris-70849-default-rtdb.firebaseio.com/orders/$id.json?auth=$authToken');
        await http.patch(
          url,
          body: json.encode({
            'clientName': order.clientName,
            'products': order.products
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
            'summ': order.summ,
            'payed': order.payed,
            'isDelivery': order.isDelivery,
            'adress': order.adress,
            'dateTime': order.dateTime.toIso8601String(),
          }),
        );
        // Обновляем заказ в списке заказов
        _orders[orderIndex] = order;
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  OrderItem findById(String id) {
    return _orders.firstWhere((order) => order.id == id);
  }

  // Удаление заказа по id
  Future<void> deleteOrder(String id) async {
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/orders/$id.json?auth=$authToken');
    // Сохраняем удаляемый заказ в existingOrder
    final existingOrderIndex = _orders.indexWhere((prod) => prod.id == id);
    OrderItem? existingOrder = _orders[existingOrderIndex];
    // Удаляем заказ из списка заказов _orders в памяти
    _orders.removeAt(existingOrderIndex);
    notifyListeners();
    // Удаляем заказ из списка заказов на сервере и сохраняем ответ с сервера
    final response = await http.delete(url);
    // Если получаем ошибку с сервера - добавляем обратно наш "удаляемый" заказ на его место
    if (response.statusCode >= 400) {
      _orders.insert(existingOrderIndex, existingOrder);
      notifyListeners();
      throw const HttpException('Could not delete product.');
    }
    existingOrder = null;
  }
}
