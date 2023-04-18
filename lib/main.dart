import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/clients.dart';
import '../providers/orders.dart';
import '../providers/products.dart';
import '../providers/products_list.dart';
import '../screens/add_clients_screen.dart';
import '../screens/add_order_screen.dart';
import '../screens/add_position_screen.dart';
import '../screens/add_product_screen.dart';
import '../screens/clients_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/splash-screen.dart';
import '../screens/products_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Подключаем провайдеров
      providers: [
        // Авторизация
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products('', '', []),
          update: (ctx, auth, previousProducts) => Products(
              auth.token!,
              auth.userId,
              previousProducts == null ? [] : previousProducts.products),
        ),
        // Продукты
        ChangeNotifierProvider(
          create: (ctx) => ProductsList(),
        ),
        // Список заказов
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders('', '', []),
          update: (ctx, auth, previousOrder) => Orders(auth.token!, auth.userId,
              previousOrder == null ? [] : previousOrder.orders),
        ),
        // Клиенты
        ChangeNotifierProxyProvider<Auth, Clients>(
          create: (_) => Clients('', '', []),
          update: (ctx, auth, previousClient) => Clients(
              auth.token!,
              auth.userId,
              previousClient == null ? [] : previousClient.clients),
        ),
      ],
      child: Consumer<Auth>(
        // Перестройка приложения когда меняется Auth
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            fontFamily: 'Lato',
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(
                  primary: const Color.fromRGBO(191, 129, 128, 1),
                  secondary: const Color.fromRGBO(15, 109, 107, 1),
                )
                .copyWith(secondary: Colors.red),
          ),
          // Выбор домашнего экрана в зависимости от аутенификации пользователя
          home: auth.isAuth
              ? const OrdersScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          // Все маршруты приложения
          routes: {
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            AddOrderScreen.routeName: (ctx) => const AddOrderScreen(),
            ProductsScreen.routeName: (ctx) => const ProductsScreen(),
            AuthScreen.routeName: (ctx) => const AuthScreen(),
            ClientsScreen.routeName: (ctx) => const ClientsScreen(),
            AddClientScreen.routeName: (ctx) => const AddClientScreen(),
            AddProductScreen.routeName: (ctx) => const AddProductScreen(),
            AddPositionScreen.routeName: (ctx) => const AddPositionScreen(),
          },
        ),
      ),
    );
  }
}
