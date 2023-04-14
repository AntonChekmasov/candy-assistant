import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

//Виждет продукта в сетке продуктов на экране отображения продуктов
class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Получаем доступ к продуктам и корзине из файла main, а также токену аутенификации
    //     listen:false - виджет не будет перестраиваться если product изменится
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 214, 210, 1),
          border: Border.all(color: Colors.black.withOpacity(0.2)),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            Flexible(
              child: SizedBox(
                width: 200,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      product.description,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // Переход на страницу сведений о продукте
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
        ),
      ),
      Consumer<Product>(
        builder: (ctx, product, _) => IconButton(
          icon: Icon(
            product.isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
          color: Colors.red,
          onPressed: () {
            // Изменение статуса любимого продукта, передача токена аутенификации
            product.toggleFavoriteStatus(authData.token, authData.userId);
          },
        ),
      ),
      Positioned(
        right: 10,
        bottom: 10,
        child: IconButton(
          icon: const Icon(
            Icons.shopping_cart,
          ),
          color: Colors.red,
          onPressed: () {
            // Добавление товара в корзину
            cart.addItem(product.id, product.price, product.title);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text(
                'Товар добавлен в карзину',
              ),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Отмена',
                textColor: Colors.red,
                onPressed: () {
                  // Отмена только что добавленного товара
                  cart.removeSingleItem(product.id);
                },
              ),
            ));
          },
        ),
      )
    ]);
  }
}
