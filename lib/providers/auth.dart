import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exeption.dart';

class Auth with ChangeNotifier {
  String? _token = '';
  late DateTime? _expiryDate = DateTime.now();
  String _userId = '';
  Timer? _authTimer = null;

// Проверка аутенифицирован ли пользователь
  bool get isAuth {
    if (_token == '') return false;
    return true;
  }

// Проверка токена
  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return '';
  }

  String get userId {
    return _userId;
  }

  // Аутенификация пользователя
  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyAjThmKRBjLygkILIpk3AbfGulSuYCpwjA');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', _token ?? 'token');
      prefs.setString('userId', _userId);
      prefs.setString('expiryDate', _expiryDate!.toIso8601String());
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signupNewUser');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('token');
    if (userToken == null) {
      return false;
    }
    final expiryDate = DateTime.parse(prefs.getString('expiryDate') ?? '');
    if (!expiryDate.isAfter(DateTime.now())) {
      return false;
    }
    _token = prefs.getString('token');
    _userId = prefs.getString('userId') ?? '';
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = '';
    _userId = '';
    _expiryDate = DateTime.now();
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToExpiry = _expiryDate?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry ?? 0), logout);
  }
}
