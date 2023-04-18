import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clients.dart';
import '../screens/add_clients_screen.dart';
import '../widgets/app_drawer.dart';

class ClientsScreen extends StatelessWidget {
  static const routeName = '/clients';

  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Клиенты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AddClientScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<Clients>(context, listen: false).fetchAndSetClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return const Center(
                  child: Text('Ошибка получения списка клиентов'));
            } else {
              return const ClientsListWidget();
            }
          }
        },
      ),
    );
  }
}

class ClientsListWidget extends StatelessWidget {
  const ClientsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем список клиентов
    final clientsList = Provider.of<Clients>(context).clients.toList();
    // Отображение списка клиентов
    return ListView.builder(
      itemCount: clientsList.length,
      itemBuilder: (ctx, i) => Card(
        child: ListTile(
          title: Text(
            clientsList[i].name,
          ),
          subtitle: Text(
            clientsList[i].tel,
          ),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              clientsList[i].name.substring(0, 1),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          trailing: IconButton(
            icon:
                Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              // Переходим на страницу редактирования выбранного клиента
              // и передаем id клиента для редактирования
              Navigator.of(context).pushNamed(AddClientScreen.routeName,
                  arguments: clientsList[i].id);
            },
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
