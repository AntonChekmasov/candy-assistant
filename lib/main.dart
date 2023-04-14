import 'package:flutter/material.dart';
import 'package:flutter_application_3/providers/clients.dart';
import 'package:flutter_application_3/providers/todo.dart';
import 'package:flutter_application_3/screens/add_clients_screen.dart';
import 'package:flutter_application_3/screens/add_order_screen.dart';
import 'package:flutter_application_3/screens/add_position_screen.dart';
import 'package:flutter_application_3/screens/add_product_screen.dart';
import 'package:flutter_application_3/screens/clients_screen.dart';
import 'package:flutter_application_3/screens/todolist_screen.dart';
import 'package:provider/provider.dart';

import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash-screen.dart';
import 'providers/category_products.dart';
import 'providers/products_list.dart';
import 'screens/products_screen.dart';

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
        // Продукты
        // ChangeNotifierProvider(
        //   create: (ctx) => CatProducts(),
        // ),
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
        //
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products('', '', []),
          update: (ctx, auth, previousProducts) => Products(
            auth.token!,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders('', '', []),
          update: (ctx, auth, previousOrders) => Orders(
            auth.token!,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
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
              ? ProductsOverviewScreen()
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
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
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
