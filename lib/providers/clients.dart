import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClientsDate {
  final String id;
  final DateTime date;
  final String description;

  ClientsDate({
    required this.id,
    required this.date,
    required this.description,
  });
}

class ClientItem {
  final String id;
  final String name;
  final String tel;
  final String adress;
  // List<ClientsDate> clientsDate;

  ClientItem({
    required this.id,
    required this.name,
    required this.tel,
    required this.adress,
    // this.clientsDate,
  });
}

class Clients with ChangeNotifier {
  String _selectedClient = '';

  String? selectedClient1 = '';

  String get sel {
    return _selectedClient;
  }

  void setSelCl(String selcl) {
    _selectedClient = selcl;
  }

  // Список товаров в корзине
  List<ClientItem> _clients = [];

  // Токен авторизации и id пользователя
  String authToken = '';
  String userId = '';

  Clients(this.authToken, this.userId, this._clients);

  // Получение списка всех клиентов
  List<ClientItem> get clients {
    return [..._clients];
  }

  // Получение количества клиентов
  int get clientsCount {
    return _clients.length;
  }

  // Поиск клиента по id
  ClientItem findById(String id) {
    return _clients.firstWhere((client) => client.id == id);
  }

  // Загрузка списка клиентов с сервера в переменную _items в памяти
  Future<void> fetchAndSetClients([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/clients.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      if (response.body.length <= 4) {
        return;
      }
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<ClientItem> loadedClients = [];
      extractedData.forEach((cliId, cliData) {
        loadedClients.add(
          ClientItem(
            id: cliId,
            name: cliData['name'],
            tel: cliData['tel'],
            adress: cliData['adress'],
          ),
        );
      });
      _clients = loadedClients;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Добавление нового клиента
  Future<void> addClient(ClientItem client) async {
    Uri url = Uri.parse(
        'https://puellaveris-70849-default-rtdb.firebaseio.com/clients.json?auth=$authToken');
    try {
      // Отправляем данные о новом продукте на сервер, получает id продукта в response.body ['name']
      final response = await http.post(
        url,
        body: json.encode({
          'name': client.name,
          'tel': client.tel,
          'adress': client.adress,
        }),
      );
      // Создаем локально нового клиента и добавляем в список клтентов _clients в памяти
      final newClient = ClientItem(
        id: json.decode(response.body)['name'],
        name: client.name,
        tel: client.tel,
        adress: client.adress,
      );
      _clients.add(newClient);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Обновление клиента
  Future<void> updateClient(String id, ClientItem newClient) async {
    // Ищем индекс обновляемого клиента
    final clientIndex = _clients.indexWhere((cli) => cli.id == id);
    try {
      if (clientIndex >= 0) {
        Uri url = Uri.parse(
            'https://puellaveris-70849-default-rtdb.firebaseio.com/clients/$id.json?auth=$authToken');
        // Обновляем поля продукта с идентификатором id на сервере
        await http.patch(
          url,
          body: json.encode(
            {
              'name': newClient.name,
              'tel': newClient.tel,
              'adress': newClient.adress,
            },
          ),
        );
        // Обновляем клиента в списке клиентов
        _clients[clientIndex] = newClient;
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }
}
