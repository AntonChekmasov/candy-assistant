import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clients.dart';

class AddClientScreen extends StatefulWidget {
  static const routeName = '/clients/add';

  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _form = GlobalKey<FormState>();

  // Переменная для хранения редактируемого клиента
  var _editedclient = ClientItem(
    adress: '',
    id: '',
    name: '',
    tel: '',
  );

  // Переменная для инициализации начальных значений формы
  var _initValues = {
    'adress': '',
    'name': '',
    'tel': '',
  };

  // Переменная для проверки инициализации виджета
  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // Получаем id клиента из аргументов
      final clientId = ModalRoute.of(context)?.settings.arguments as String?;
      // Если есть id клиента
      if (clientId != null) {
        // Ищем клиента по id
        _editedclient =
            Provider.of<Clients>(context, listen: false).findById(clientId);
        // Заполняем поля формы если редактируем клиента
        _initValues = {
          'adress': _editedclient.adress,
          'name': _editedclient.name,
          'tel': _editedclient.tel,
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
    // Если у клиента есть id - мы в режиме редактирования
    if (_editedclient.id != '') {
      Provider.of<Clients>(context, listen: false)
          .updateClient(_editedclient.id, _editedclient);
    } else {
      // Иначе - добавляем нового клиента
      Provider.of<Clients>(context, listen: false).addClient(_editedclient);
    }
    Navigator.of(context).pop();
  }

  // Верстка страницы
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый клиент'),
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _userAvatar(),
                  const SizedBox(height: 30),
                  _userName(),
                  const SizedBox(height: 15),
                  _userTel(),
                  const SizedBox(height: 15),
                  _userAdress(),
                  const SizedBox(height: 15),
                  _userNotes(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Аватар
  _userAvatar() {
    return const CircleAvatar(
      radius: 70,
      child: Text('A'),
    );
  }

  // Поле 'Имя клиента'
  _userName() {
    return TextFormField(
      initialValue: _initValues['name'],
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(10),
        border: OutlineInputBorder(),
        labelText: 'Имя клиента',
      ),
      textInputAction: TextInputAction.next,
      onSaved: (newValue) {
        _editedclient = ClientItem(
          id: _editedclient.id,
          name: newValue ?? '',
          tel: _editedclient.tel,
          adress: _editedclient.adress,
        );
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Введите имя клиента';
        }
        return null;
      },
    );
  }

  // Поле 'Телефон'
  _userTel() {
    return TextFormField(
      initialValue: _initValues['tel'],
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(10),
        border: OutlineInputBorder(),
        labelText: 'Телефон',
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      onSaved: (newValue) {
        _editedclient = ClientItem(
          id: _editedclient.id,
          name: _editedclient.name,
          tel: newValue ?? '',
          adress: _editedclient.adress,
        );
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Введите телефон';
        }
        return null;
      },
    );
  }

  // Поле 'Адрес'
  _userAdress() {
    return TextFormField(
      initialValue: _initValues['adress'],
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(10),
        border: OutlineInputBorder(),
        labelText: 'Адрес',
      ),
      textInputAction: TextInputAction.next,
      onSaved: (newValue) {
        _editedclient = ClientItem(
          id: _editedclient.id,
          name: _editedclient.name,
          tel: _editedclient.tel,
          adress: newValue ?? '',
        );
      },
    );
  }

  // Поле 'Заметки'
  _userNotes() {
    return TextFormField(
      maxLines: 5,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(10),
        border: OutlineInputBorder(),
        labelText: 'Заметки',
      ),
      keyboardType: TextInputType.multiline,
    );
  }
}
