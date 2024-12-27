import 'package:adwaita_icons/adwaita_icons.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/auth.dart';
import 'package:frontend/controllers/secrets.dart';
import 'package:frontend/controllers/utils.dart';
import 'package:frontend/widgets.dart';
import 'package:provider/provider.dart';

class SecretsPage extends StatefulWidget {
  const SecretsPage({super.key});

  @override
  State<SecretsPage> createState() => _SecretsPageState();
}

class _SecretsPageState extends State<SecretsPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final secretsNotifier = SecretsNotifier();
        secretsNotifier.loadSecretsFromServer(context);
        return secretsNotifier;
      },
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Lafzify'),
          actions: [
            IconButton(
              tooltip: 'Log Out',
              icon: const AdwaitaIcon(
                AdwaitaIcons.system_log_out,
                semanticLabel: 'Log Out',
              ),
              onPressed: () {
                Provider.of<AuthNotifier>(context, listen: false).signOut();
              },
            ),
            IconButton(
                onPressed: () =>
                    Provider.of<SecretsNotifier>(context, listen: false).loadSecretsFromServer(context),
                icon: const AdwaitaIcon(AdwaitaIcons.view_refresh, semanticLabel: 'Refresh',),
                tooltip: 'Refresh'
            ),
          ],
        ),
        body: Center(child: Consumer<SecretsNotifier>(
          builder: (context, pro, _) {
            if (pro.status == PageStatus.loading) {
              return const CircularProgressIndicator();
            } else if (pro.status == PageStatus.error) {
              return PageErrorWidget(failedLoadingWhat: "secrets", retryFunction: () => pro.loadSecretsFromServer(context),);
            }
            
            return SingleChildScrollView(
              child: Column(
                children: [
                  
                ]
              ),
            );
          },
        )),
      ),
    );
  }
}

