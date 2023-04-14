// Экран добавления/редактирования товаров

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_products.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/products/add';

  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _form = GlobalKey<FormState>();

  // Переменная для хранения редактируемого продукта
  var _editedProduct = ProductItem(
    id: '',
    isWeight: false,
    title: '',
    price: 0,
    cost: 0,
  );

  // Переменная для инициализации начальных значений формы
  var _initValues = {
    'title': '',
    'price': '0',
    'cost': '0',
  };

  // Переменная для хранения значения переключателя шт/кг
  bool _isWeight = false;

  // Переменная для проверки инициализации виджета
  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // Получаем id продукта из аргументов
      final productId = ModalRoute.of(context)?.settings.arguments as String?;
      // Если есть id продукта
      if (productId != null) {
        // Ищем продукт по id
        _editedProduct = Provider.of<CatProducts>(context, listen: false)
            .findById(productId);
        // Заполняем поля формы если редактируем клиента
        _initValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'cost': _editedProduct.cost.toString(),
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  _saveForm() {
    // Проверка валидации формы
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    // Сохраняем состояние формы
    _form.currentState?.save();
    // Если у клиента есть id - мы в режиме редактирования - обновляем продукт
    if (_editedProduct.id != '') {
      Provider.of<CatProducts>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      // Иначе - добавляем новый продукт
      Provider.of<CatProducts>(context, listen: false)
          .addProductr(_editedProduct);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый продукт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          ),
        ],
      ),
      body: Form(
          key: _form,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(),
                        labelText: 'Название товара',
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (newValue) {
                        _editedProduct = ProductItem(
                          id: _editedProduct.id,
                          title: newValue ?? '',
                          isWeight: _editedProduct.isWeight,
                          price: _editedProduct.price,
                          cost: _editedProduct.cost,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Введите название товара';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Цена за 1: шт. '),
                        Switch(
                          value: _isWeight,
                          onChanged: (val) {
                            setState(() {
                              _isWeight = val;
                            });
                          },
                        ),
                        const Text(' 1 кг.'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Поле цена
                    TextFormField(
                      initialValue: _initValues['price'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(),
                        labelText: 'Цена',
                        suffix: Text('руб.'),
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (newValue) {
                        _editedProduct = ProductItem(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          isWeight: _editedProduct.isWeight,
                          price: double.parse(newValue ?? '0'),
                          cost: _editedProduct.cost,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty || value == '0') {
                          return 'Введите цену товара';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Поле себестоимость
                    TextFormField(
                      initialValue: _initValues['cost'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(),
                        labelText: 'Себестоимость',
                        suffix: Text('руб.'),
                      ),
                      onSaved: (newValue) {
                        _editedProduct = ProductItem(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          isWeight: _editedProduct.isWeight,
                          price: _editedProduct.price,
                          cost: double.parse(newValue ?? '0'),
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty || value == '0') {
                          return 'Введите себестоимость товара';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
