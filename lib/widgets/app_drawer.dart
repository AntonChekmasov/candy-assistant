// Виджет боковой панели

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/clients_screen.dart';
import '../screens/products_screen.dart';
import '../screens/orders_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Candy Assistant'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.shop_2_outlined),
            title: const Text('Заказы'),
            onTap: () {
              Navigator.of(context).pushNamed(OrdersScreen.routeName);
            },
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
            leading: const Icon(Icons.store),
            title: const Text('Товары'),
            onTap: () {
              Navigator.of(context).pushNamed(ProductsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Выход из системы'),
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
