import 'package:adwaita_icons/adwaita_icons.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/auth.dart';
import 'package:frontend/controllers/utils.dart';
import 'package:frontend/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_path.dart';
import 'controllers/jobs.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final jobsNotifier = JobsNotifier();
        jobsNotifier.loadJobs(context);
        return jobsNotifier;
      },
      builder: (context, _) => Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {}, child: const AdwaitaIcon(AdwaitaIcons.tab_new)),
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
                    Provider.of<JobsNotifier>(context, listen: false).loadJobs(context),
                icon: const AdwaitaIcon(AdwaitaIcons.view_refresh, semanticLabel: 'Refresh',),
                tooltip: 'Refresh'
            ),
          ],
        ),
        body: Center(child: Consumer<JobsNotifier>(
          builder: (context, pro, _) {
            if (pro.status == PageStatus.loading) {
              return const CircularProgressIndicator();
            } else if (pro.status == PageStatus.error) {
              return PageErrorWidget(retryFunction: () => pro.loadJobs(context), failedLoadingWhat: "jobs",);
            }
            return ListView.builder(
                itemCount: pro.jobs.length,
                itemBuilder: (context, idx) {
                  var job = pro.jobs[idx];
                  var status = job.status;
                  return ListTile(
                    onTap: () {
                      if (pro.jobs[idx].post_url != null) {
                        launchUrl(Uri.parse(job.post_url!));
                      }
                    },
                    leading: Image.network(
                        "$API_PATH/static/${job.platform_id}.png"),
                    title: Text(
                      job.text,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: status == JobStatus.failed
                        ? Text(
                            "Failed (${job.failed_reason})",
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text("Created at ${job.time.toString()}"),
                    trailing: status == JobStatus.pending
                        ? const AdwaitaIcon(AdwaitaIcons.document_open_recent)
                        : status == JobStatus.completed
                            ? const AdwaitaIcon(AdwaitaIcons.go_next)
                            : const AdwaitaIcon(AdwaitaIcons.computer_fail),
                  );
                });
          },
        )),
      ),
    );
  }
}
