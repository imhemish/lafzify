import 'dart:convert';
import 'dart:developer';
import 'utils.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/auth.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/api_path.dart';
import 'package:provider/provider.dart';

class SecretsModel {
  final String? gemini;
  final List<ApiCredentials> platforms;

  SecretsModel({required this.gemini, required this.platforms});

  factory SecretsModel.fromJson(Map<String, dynamic> json) {
    return SecretsModel(
      gemini: json['gemini'],
      platforms: (json['platforms'] as List).map((e) => ApiCredentials.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gemini': gemini,
      'platformss': platforms.map((e) => e.toJson()).toList(),
    };
  }
}

class ApiCredentials {
  
  final String platform_id;
  final String apiKey;
  final String apiSecret;
  final String accessToken;
  final String accessSecret;

  ApiCredentials({
    required this.platform_id,
    required this.apiKey,
    required this.apiSecret,
    required this.accessToken,
    required this.accessSecret,
  });

  factory ApiCredentials.fromJson(Map<String, dynamic> json) {
    return ApiCredentials(
      platform_id: json['platform_id'],
      apiKey: json['api_key'],
      apiSecret: json['api_secret'],
      accessToken: json['access_token'],
      accessSecret: json['access_secret'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform_id': platform_id,
      'api_key': apiKey,
      'api_secret': apiSecret,
      'access_token': accessToken,
      'access_secret': accessSecret,
    };
  }
}

class SecretsNotifier extends ChangeNotifier {
  final secretsPath = "$API_PATH/secrets";

  // initial state is loading
  PageStatus status = PageStatus.loading;

  SecretsModel? _secrets;

  SecretsModel? get secrets => _secrets;

  void setSecrets(SecretsModel secrets) {
    _secrets = secrets;
    status = PageStatus.loaded;
    notifyListeners();
  }

  void loadSecretsFromServer(BuildContext context) async {
    try {
    final authProvider = Provider.of<AuthNotifier>(context, listen: false);
    var resp = await http.get(Uri.parse(secretsPath), headers: {
      "Authorization": "Bearer ${authProvider.accessToken}"
    });
    if (resp.statusCode == 200) {
      setSecrets(SecretsModel.fromJson(jsonDecode(resp.body)));
      return;
    } else if (resp.statusCode == 401) {
      authProvider.signOut();
      return;
    }
    } catch (e) {
      log(e.toString());
    }
    status = PageStatus.error;
    notifyListeners();
    
  }

  void sendSecretsToServer(BuildContext context) async {
    status = PageStatus.loading;
    notifyListeners();
    try {
    final authProvider = Provider.of<AuthNotifier>(context, listen: false);
    var resp = await http.put(Uri.parse(secretsPath), headers: {
      "Authorization": "Bearer ${authProvider.accessToken}"
    }, body: _secrets?.toJson());
    if (resp.statusCode == 200) {
      setSecrets(secrets!);
      return;
    } else if (resp.statusCode == 401) {
      authProvider.signOut();
      return;
    }
    } catch (e) {
      log(e.toString());
    }
    status = PageStatus.error;
    notifyListeners();
  }
}