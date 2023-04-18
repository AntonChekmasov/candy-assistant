import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../models/http_exeption.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          _pageGradient(),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _logo(),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Фоновый градиент
  _pageGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
            const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0, 1],
        ),
      ),
    );
  }

  // Лого
  _logo() {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
        transform: Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 223, 129, 101),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black26,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: const Text(
          'Candy Assistant',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Форма авторизации
class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _emailInput(),
                _passInput(),
                _retryPassInput(),
                const SizedBox(height: 20),
                _buttonLogin(),
                _buttonRegister(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Поле ввода e-mail
  _emailInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'E-Mail'),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty || !value.contains('@')) {
          return 'Неверный формат e-mail';
        }
        return null;
      },
      onSaved: (value) {
        _authData['email'] = value!;
      },
    );
  }

  // Поле ввода пароля
  _passInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Пароль'),
      obscureText: true,
      controller: _passwordController,
      validator: (value) {
        if (value!.isEmpty || value.length < 5) {
          return 'Пароль слишком короткий';
        }
      },
      onSaved: (value) {
        _authData['password'] = value!;
      },
    );
  }

  // Поле подтверждения пароля при регистрации
  _retryPassInput() {
    if (_authMode == AuthMode.Signup) {
      return TextFormField(
        enabled: _authMode == AuthMode.Signup,
        decoration: const InputDecoration(labelText: 'Подтвердите пароль'),
        obscureText: true,
        validator: _authMode == AuthMode.Signup
            ? (value) {
                if (value != _passwordController.text) {
                  return 'Пароли не совпадают';
                }
              }
            : null,
      );
    } else {
      return const SizedBox(height: 1);
    }
  }

  // Кнопка Войти
  _buttonLogin() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    } else {
      return ElevatedButton(
        onPressed: _submit,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          )),
        ),
        child: Text(_authMode == AuthMode.Login ? 'Войти' : 'Регистрация'),
      );
    }
  }

  // Кнопка Регистрация
  _buttonRegister() {
    return TextButton(
      onPressed: _switchAuthMode,
      child: Text('${_authMode == AuthMode.Login ? 'Регистрация' : 'Войти'}'),
    );
  }

  // Диалог ошибки
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Ok'),
          )
        ],
      ),
    );
  }

  // Вход в систему / регистрация
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email']!, _authData['password']!);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false)
            .signup(_authData['email']!, _authData['password']!);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Аутенификация не удалась';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Адрес электронной почты уже используется';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Неверный адрес электронной почты';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Пользователь не найден';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Неверный пароль';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Не удалось проверить подлинность. Повторите попытку позже';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Переключение метода авторизации
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }
}
