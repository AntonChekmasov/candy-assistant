import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './providers/clients.dart';
import './providers/todo.dart';
import './providers/category_products.dart';
import './providers/products_list.dart';
import './screens/add_clients_screen.dart';
import './screens/add_order_screen.dart';
import './screens/add_position_screen.dart';
import './screens/add_product_screen.dart';
import './screens/clients_screen.dart';
import './screens/todolist_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash-screen.dart';
import './screens/products_screen.dart';

void main() => runApp(MyApp());

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
        ChangeNotifierProxyProvider<Auth, CatProducts>(
          create: (_) => CatProducts('', '', []),
          update: (ctx, auth, previousProducts) => CatProducts(
              auth.token!,
              auth.userId,
              previousProducts == null ? [] : previousProducts.products),
        ),
        // Продукты
        ChangeNotifierProvider(
          create: (ctx) => ProductsList(),
        ),
        // Список заказов
        ChangeNotifierProvider(
          create: (ctx) => OrderTodo(),
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
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Color.fromRGBO(191, 129, 128, 1),
              secondary: Color.fromRGBO(15, 109, 107, 1),
            ),
            accentColor: Colors.red,
            fontFamily: 'Lato',
          ),
          // Выбор домашнего экрана в зависимости от аутенификации пользователя
          home: auth.isAuth
              ? Todolist()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          // Все маршруты приложения
          routes: {
            Todolist.routeName: (ctx) => Todolist(),
            AddOrderScreen.routeName: (ctx) => AddOrderScreen(),
            ProductsScreen.routeName: (ctx) => ProductsScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            ClientsScreen.routeName: (ctx) => ClientsScreen(),
            AddClientScreen.routeName: (ctx) => AddClientScreen(),
            AddProductScreen.routeName: (ctx) => AddProductScreen(),
            AddPositionScreen.routeName: (ctx) => AddPositionScreen(),
          },
        ),
      ),
    );
  }
}
