import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/add_product_screen.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';

class ProductsScreen extends StatelessWidget {
  static const routeName = '/products';

  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Товары'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AddProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<Products>(context, listen: false).fetchAndSetProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return const Center(child: Text('Ошибка выполнения запроса'));
            } else {
              return const ProductsListWidget();
            }
          }
        },
      ),
    );
  }
}

class ProductsListWidget extends StatelessWidget {
  const ProductsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем список продукции
    final productsList = Provider.of<Products>(context).products.toList();
    return ListView.builder(
      itemCount: productsList.length,
      itemBuilder: (ctx, i) => Card(
        child: ListTile(
          title: Text(
            productsList[i].title,
          ),
          subtitle: Text(
            productsList[i].price.toString(),
          ),
          trailing: IconButton(
            icon:
                Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              // Переходим на страницу редактирования выбранного продукта
              // и передаем id продукта для редактирования
              Navigator.of(context).pushNamed(AddProductScreen.routeName,
                  arguments: productsList[i].id);
            },
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
