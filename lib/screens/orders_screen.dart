import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import '../providers/orders.dart';
import '../screens/add_order_screen.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});
  // Верстка страницы
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список заказов'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return const Center(
                  child: Text('Ошибка получения списка заказов'));
            } else {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopInfoWidget(),
                    const SizedBox(height: 20),
                    _OrdersListWidget()
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}

// Информация 'Сегодня', кнопка 'Добавить заказ', календарь
class _TopInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Сегодня',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('dd  MMMM  yyyy').format(DateTime.now()),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AddOrderScreen.routeName);
              },
              child: const Text('+ Добавить заказ'),
            )
          ],
        ),
        const SizedBox(height: 20),
        DatePicker(
          DateTime.now(),
          deactivatedColor: Colors.grey,
          height: 100,
          width: 60,
          locale: 'ru',
          //     activeDates: [DateTime(2023, 4, 21), DateTime(2023, 4, 13)],
          onDateChange: (selectedDate) {},
        ),
      ],
    );
  }
}

// Список карточек заказов
class _OrdersListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _ordersList = Provider.of<Orders>(context);
    return Container(
      child: (_ordersList.orders.isEmpty)
          ? const Text('Нет заказов')
          : Expanded(
              child: ListView.builder(
                itemCount: _ordersList.orders.length,
                itemBuilder: (context, i) =>
                    OrderItemWidget(_ordersList.orders[i]),
              ),
            ),
    );
  }
}

// Карточка заказа
class OrderItemWidget extends StatelessWidget {
  final OrderItem order;
  const OrderItemWidget(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _openModalBottomSheet(context);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _userInfo(context),
                    _listOfPosition(),
                    _deliveryInfo(),
                    _dateInfo(),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: 80,
                width: 0.5,
                color:
                    const Color.fromARGB(255, 219, 127, 127).withOpacity(0.7),
              ),
              RotatedBox(
                quarterTurns: 3,
                child: Text('Новый'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Информация о заказчике и сумма заказа
  _userInfo(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            order.clientName.substring(0, 1),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.clientName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
            Text('${order.summ.toString()} руб.'),
          ],
        )
      ],
    );
  }

  // Список продукции в заказе
  _listOfPosition() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: order.products
            .map(
              (prod) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    prod.title,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${prod.quantity} x ${prod.price} руб.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  // Информация о доставке
  _deliveryInfo() {
    return order.isDelivery
        ? Text('Доставка: ${order.adress}')
        : const Text('Самовывоз');
  }

  // Дата и время выдачи заказа
  _dateInfo() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Text(
        DateFormat('dd MMMM yyyy   hh:mm').format(order.dateTime),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.end,
      ),
    );
  }

  // Нижнее модальное окно
  _openModalBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 160,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Действия:'),
                ElevatedButton(
                  child: const Text('Редактировать'),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(AddOrderScreen.routeName, arguments: order.id),
                ),
                ElevatedButton(
                  child: const Text('Удалить'),
                  onPressed: () {
                    // Удаление заказа
                    Provider.of<Orders>(context, listen: false)
                        .deleteOrder(order.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
