import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../providers/products_list.dart';

class TodoItem {
  final String id;
  final String clientName;
  final List<ProductItem> products;
  final double summ;
  final double payed;
  final bool isDelivery;
  final String adress;
  final DateTime dateTime;

  TodoItem({
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

class OrderTodo with ChangeNotifier {
  List<TodoItem> _orders = [
    TodoItem(
        id: '1',
        clientName: 'clientName',
        products: [],
        summ: 2000,
        payed: 1000,
        isDelivery: true,
        adress: 'adress',
        dateTime: DateTime.now())
  ];

  List<TodoItem> get orders {
    return [..._orders];
  }

  addOrder(
    String clientName,
    List<ProductItem> products,
    double summ,
    double payed,
    bool isDelivery,
    String adress,
    DateTime dateTime,
  ) {
    _orders.add(TodoItem(
      id: DateTime.now().toString(),
      clientName: clientName,
      products: products,
      summ: summ,
      payed: payed,
      isDelivery: isDelivery,
      adress: adress,
      dateTime: dateTime,
    ));
    notifyListeners();
  }

  TodoItem findById(String id) {
    return _orders.firstWhere((order) => order.id == id);
  }
}
