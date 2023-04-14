import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/add_product_screen.dart';
import 'package:provider/provider.dart';

import '../providers/category_products.dart';

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
      body: FutureBuilder(
        future: Provider.of<CatProducts>(context, listen: false)
            .fetchAndSetProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return const Center(child: Text('An error occurred!'));
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
    final productsList = Provider.of<CatProducts>(context).products.toList();
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
