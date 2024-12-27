import 'dart:developer';

import 'package:adwaita/adwaita.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/auth.dart';
import 'package:frontend/home.dart';
import 'package:frontend/login.dart';
import 'package:frontend/sign_up.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Auth affects the whole app, as soon as auth is failed, we go to Login
      create: (context) {
        final authNotifier = AuthNotifier();
        authNotifier.loadTokens();
        return authNotifier;
      },
      child: Consumer<AuthNotifier>(
        builder: (context, pro, _) {
          log("Authenticated: ${pro.isAuthenticated}");
          return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lafzify',
          theme: AdwaitaThemeData.light(),
          darkTheme: AdwaitaThemeData.dark(),
          home: pro.isAuthenticated ? const HomePage() : const LoginPage(),
          routes: {
            "/login": (context) => const LoginPage(),
            "/signup": (context) => const SignUpPage(),
          },
        );
        },
      ),
    );
  }
}