import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../providers/products.dart';
import '../screens/add_position_screen.dart';
import '../providers/clients.dart';
import '../providers/products_list.dart';
import '../providers/orders.dart';

class AddOrderScreen extends StatefulWidget {
  static const routeName = '/todolist/add_order';

  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  // Ключ формы
  final GlobalKey<FormState> _formKey = GlobalKey();

  // Переменная для хранения редактируемого заказа
  var _editedOrderItem = OrderItem(
    id: '',
    products: [],
    adress: '',
    clientName: '',
    dateTime: DateTime.now(),
    isDelivery: false,
    payed: 0,
    summ: 0,
  );

  // Переменная для хранения списка добавленных продуктов в заказ
  late ProductsList _cart;

  // Переменная для хранения суммы предоплаты
  double _prepay = 0;

  // Переменная для хранения способа доставки
  bool _isDelivery = false;

  // Переменная для хранения адреса доставки
  var _adressController = TextEditingController(text: '');

  //Переменная для хранения даты и времени заказа
  DateTime _date = DateTime.now();

  // Переменная для хранения выбранного клиента
  String? _selectedClient;

  // Переменная для проверки инициализации виджета
  var _isInit = true;
  var orderId = '';
  @override
  void didChangeDependencies() {
    if (_isInit) {
      // Загружаем список клиентов и список продукции
      Provider.of<Clients>(context).fetchAndSetClients();
      Provider.of<Products>(context).fetchAndSetProducts();
      _cart = Provider.of<ProductsList>(context);
      // Получаем id заказа из аргументов
      orderId = ModalRoute.of(context)?.settings.arguments as String? ?? '';
      // Если есть id заказа
      if (orderId != '') {
        // Ищем заказ по id
        _editedOrderItem =
            Provider.of<Orders>(context, listen: false).findById(orderId);
        // Заполняем поля если редактируем заказ
        _isDelivery = _editedOrderItem.isDelivery;
        _date = _editedOrderItem.dateTime;
        _selectedClient = _editedOrderItem.clientName;
        _prepay = _editedOrderItem.payed;
        _adressController.text = _editedOrderItem.adress;
        for (var prod in _editedOrderItem.products) {
          _cart.addItem(prod.id, prod.price, prod.title, prod.quantity, false);
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  // Очищаем список товаров при закрытии окна
  @override
  void dispose() {
    _cart.clear();
    super.dispose();
  }

  // Верстка страницы
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: orderId == ''
              ? const Text('Новый заказ')
              : const Text('Редактировать заказ'),
        ),
        //   bottomSheet: ,

        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _addSelectClient(),
                  const SizedBox(height: 10),
                  _addProductsList(),
                  const SizedBox(height: 10),
                  _addPaymentInfo(),
                  const SizedBox(height: 10),
                  _addDeliveryInfo(),
                  _addDateInfo(),
                  const SizedBox(height: 10),
                  _addConfirmButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Блок выбора клиента
  _addSelectClient() {
    // Список клиентов
    final clients = Provider.of<Clients>(context);
    return DropdownButtonFormField2(
      hint: const Text('Выберите клиента'),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(11),
        border: OutlineInputBorder(),
      ),
      items: clients.clients
          .map((item) => DropdownMenuItem<String>(
                value: item.name,
                child: Text(item.name),
              ))
          .toList(),
      value: _selectedClient,
      validator: (value) {
        if (value == '' || value == null) {
          return 'Выбирите клиента';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _selectedClient = value;
        });
      },
    );
  }

  // Блок добавления продукции в заказ
  _addProductsList() {
    return Column(
      children: [
        const Text('Список товаров:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _cart.itemCount > 0
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cart.items.length,
                itemBuilder: (context, i) =>
                    _productCard(_cart.items.values.toList()[i]),
              )
            : const Text('Нет товаров'),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(AddPositionScreen.routeName);
          },
          icon: const Icon(Icons.add),
          label: const Text(''),
        ),
      ],
    );
  }

  _productCard(ProductListItem prod) {
    return Card(
      margin: const EdgeInsets.all(1),
      child: ListTile(
        title: Text(prod.title),
        subtitle:
            Text('${prod.quantity.toString()} x  ${prod.price.toString()}'),
        trailing: IconButton(
            onPressed: () {
              Provider.of<ProductsList>(context, listen: false)
                  .removeItem(prod.id);
              setState(() {});
            },
            icon: const Icon(Icons.delete)),
      ),
    );
  }

  // Блок финансовой информации
  _addPaymentInfo() {
    final prepayController = TextEditingController(text: '0');
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Итого: ${_cart.totalAmount} руб.   '),
          TextButton(
            onPressed: () {
              prepayController.text = _prepay.toString();
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Сумма предоплаты'),
                  content: TextField(
                    controller: prepayController,
                    keyboardType: TextInputType.number,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _prepay = double.parse(prepayController.text);
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: (_prepay > 0)
                ? Text('Предоплата: $_prepay руб.')
                : const Text('Добавить предоплату'),
          ),
          Text('Остаток: ${_cart.totalAmount - _prepay} руб.   '),
        ],
      ),
    );
  }

  // Блок информации о доставке
  _addDeliveryInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Самовывоз '),
            Switch(
              value: _isDelivery,
              onChanged: (val) {
                setState(() {
                  _isDelivery = val;
                });
              },
            ),
            const Text(' Доставка'),
          ],
        ),
        const SizedBox(height: 10),
        if (_isDelivery)
          TextFormField(
            controller: _adressController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(10),
              border: OutlineInputBorder(),
              labelText: 'Адрес доставки',
            ),
            textInputAction: TextInputAction.next,
            onSaved: (newValue) {},
            validator: (value) {
              if (value!.isEmpty || value == '0') {
                return 'Введите адрес доставки';
              }
              return null;
            },
          ),
      ],
    );
  }

  // Блок информации о дате выполнения заказа
  _addDateInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () async {
              final selDate = await pickDate();
              if (selDate == null) return;
              setState(() {
                _date = selDate;
              });
            },
            child: Text('Дата: ${_date.day}/${_date.month}/${_date.year}'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextButton(
            child: Text('Время: ${_date.hour}:${_date.minute}'),
            onPressed: () async {
              final time = await pickTime();
              if (time == null) return;
              final newDate = DateTime(
                  _date.year, _date.month, _date.day, time.hour, time.minute);
              setState(() {
                _date = newDate;
              });
            },
          ),
        )
      ],
    );
  }

  // Кнопка 'Создать заказ'
  _addConfirmButton() {
    // Список заказов
    final ordersList = Provider.of<Orders>(context);
    return ElevatedButton(
      onPressed: () {
        if (!_formKey.currentState!.validate()) {
          // Invalid!
          return;
        }
        // Если есть id заказа
        if (_editedOrderItem.id != '') {
          // Обновляем заказ
          ordersList.updateOrder(
            _editedOrderItem.id,
            OrderItem(
              id: _editedOrderItem.id,
              clientName: _selectedClient ?? 'AAA',
              products: _cart.items.values.toList(),
              summ: _cart.totalAmount,
              payed: _prepay,
              isDelivery: _isDelivery,
              adress: _adressController.text,
              dateTime: _date,
            ),
          );
        } else {
          // Создаем новый заказ
          ordersList.addOrder(
            OrderItem(
              id: '',
              clientName: _selectedClient ?? 'AAA',
              products: _cart.items.values.toList(),
              summ: _cart.totalAmount,
              payed: _prepay,
              isDelivery: _isDelivery,
              adress: _adressController.text,
              dateTime: _date,
            ),
          );
        }
        _cart.clear();
        setState(() {});
        Navigator.of(context).pushReplacementNamed('/');
      },
      child: orderId == ''
          ? const Text('Создать заказ')
          : const Text('Сохранить изменения'),
    );
  }

  // Окно выбора даты выдачи заказа
  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime.now(),
        lastDate: DateTime(2030),
      );

  // Окно выбора времени выдачи заказа
  Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: _date.hour, minute: _date.minute),
      );
}
