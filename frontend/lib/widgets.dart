import 'package:adwaita_icons/adwaita_icons.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/secrets.dart';

class PageErrorWidget extends StatelessWidget {
  final String failedLoadingWhat;
  final Function() retryFunction;

  const PageErrorWidget(
      {super.key, this.failedLoadingWhat = "", required this.retryFunction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AdwaitaIcon(
              AdwaitaIcons.computer_fail,
              size: 50,
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Failed loading $failedLoadingWhat"),
            const SizedBox(
              height: 10,
            ),
            TextButton(onPressed: retryFunction, child: const Text("Retry"))
          ]),
    );
  }
}


class PlatformSecrets extends StatelessWidget {
  final ApiCredentials apiCredentials;

  const PlatformSecrets({super.key, required this.apiCredentials});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Text(apiCredentials.platform_id),
            const SizedBox(height: 10,),

            
          ],
        )),
    );
  }
}