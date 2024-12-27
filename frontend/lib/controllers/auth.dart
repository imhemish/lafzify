import 'package:flutter/foundation.dart';
import '../api_path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  String? _tokenType;

  bool get isAuthenticated => _accessToken != null;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get tokenType => _tokenType;

  Future<void> signIn(String username, String password) async {
    final url = Uri.parse('$API_PATH/token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        _tokenType = data['token_type'];

        await _saveTokens();

        notifyListeners();
      } else {
        throw Exception('Failed to sign in: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during sign-in: $e');
    }
  }

  Future<void> _saveTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', _accessToken ?? '');
    await prefs.setString('refresh_token', _refreshToken ?? '');
    await prefs.setString('token_type', _tokenType ?? '');
  }

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    _tokenType = prefs.getString('token_type');
    for (var i in [_accessToken, _refreshToken, _tokenType]) {
      if (i == "") {
        i = null;
      }
    }
    notifyListeners();
  }

  Future<void> refreshTokenFromAPI() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final url = Uri.parse('$API_PATH/refresh');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': _refreshToken!,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        _tokenType = data['token_type'];

        await _saveTokens();

        notifyListeners();
      } else {
        throw Exception('Failed to refresh token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during token refresh: $e');
    }
  }

  Future<String?> getToken() async {
    if (_accessToken != null) {
      return _accessToken;
    }

    await loadTokens();

    if (_accessToken != null) {
      return _accessToken;
    } else if (_refreshToken != null) {
      await refreshTokenFromAPI();
      return _accessToken;
    } else {
      return null;
    }
  }

  void signOut() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenType = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}