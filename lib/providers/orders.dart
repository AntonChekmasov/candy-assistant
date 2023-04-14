// Список заказов

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  // Загрузка списка заказов с сервера в переменную _orders в памяти
  Future<void> fetchAndSetOrders() async {
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      if (response.body.contains('error')) {
        return;
      }

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];

      extractedData.forEach((OrderId, orderData) {
        loadedOrders.add(OrderItem(
          id: OrderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ))
              .toList(),
        ));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Добавление заказа на сервер
  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    //  var url = Uri.https(
    //      'puellaveris-70849-default-rtdb.firebaseio.com', '/orders.json');
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();
    final responce = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList()
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(responce.body)['name'],
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
