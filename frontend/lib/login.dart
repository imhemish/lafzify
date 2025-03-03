import 'package:flutter/material.dart';
import 'package:frontend/controllers/auth.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(const Size(400, double.infinity)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(height: 10,),
                TextButton(onPressed: () {
                  try {
                    // app is already listening to it, and will respond with going to correct page if signed in
                  Provider.of<AuthNotifier>(context, listen: false).signIn(_usernameController.text, _passwordController.text);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }, child: const Text("Login", ),),
                const SizedBox(height: 20,),
                const Text("Don't have an account?"),
                const SizedBox(height: 10,),
                
                TextButton(onPressed: () => Navigator.pushReplacementNamed(context, "/signup"), child: const Text("Sign Up"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}