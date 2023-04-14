import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_products.dart';
import '../providers/products_list.dart';

class AddPositionScreen extends StatefulWidget {
  static const routeName = '/todolist/add_order/add_position';

  const AddPositionScreen({super.key});

  @override
  State<AddPositionScreen> createState() => _AddPositionScreenState();
}

class _AddPositionScreenState extends State<AddPositionScreen> {
  //ProductItem _addedProducts = {};
  var selectedIndex = -1;
  var selectrdProduct;
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<ProductsList>(context);

    final _products = Provider.of<CatProducts>(context).products;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбирите позицию'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _products.length,
                  itemBuilder: _createListView,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                    labelText: "Количество", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                controller: myController,
              ),
              TextButton(
                  onPressed: () {
                    cart.addItem(
                        _products[selectedIndex].id,
                        _products[selectedIndex].price,
                        _products[selectedIndex].title,
                        int.parse(myController.text),
                        true);

                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Добавить')),
            ]),
      ),
    );
  }

  Widget _createListView(BuildContext context, int index) {
    final _products = Provider.of<CatProducts>(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          // устанавливаем индекс выделенного элемента
          selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: index == selectedIndex ? Colors.black12 : Colors.white60,
        child: Text(_products.products[index].title,
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
