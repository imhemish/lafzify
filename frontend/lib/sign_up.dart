import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
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
                TextButton(onPressed: () {}, child: const Text("Sign Up", ),),
                const SizedBox(height: 20,),
                const Text("Already have an account?"),
                const SizedBox(height: 10,),
                TextButton(onPressed: () => Navigator.pushReplacementNamed(context, "/login"), child: const Text("Log In"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}