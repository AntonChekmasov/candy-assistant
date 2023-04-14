// Виджет боковой панели

import 'package:flutter/material.dart';
import 'package:flutter_application_3/providers/clients.dart';
import 'package:flutter_application_3/screens/auth_screen.dart';
import 'package:flutter_application_3/screens/clients_screen.dart';
import 'package:flutter_application_3/screens/products_screen.dart';
import 'package:flutter_application_3/screens/todolist_screen.dart';
import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('PuellaVeris Cake'),
            automaticallyImplyLeading: false,
          ),
          // Магазин
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Клиенты'),
            onTap: () {
              Navigator.of(context).pushNamed(ClientsScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.money_off_csred_rounded),
            title: const Text('Выдача заказов'),
            onTap: () {
              Navigator.of(context).pushNamed(Todolist.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Товары'),
            onTap: () {
              Navigator.of(context).pushNamed(ProductsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Продукция'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          // Заказы
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Заказы'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),
          // Менеджер продуктов
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Manage Products'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          // Выход из системы
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              // Возврат на домашний экран
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
