import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/api_path.dart';
import 'package:frontend/controllers/auth.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'utils.dart';
enum JobStatus {
  pending, completed, failed
}

class Job {
  final String id;
  final String platform_id;
  final String text;
  final DateTime time;
  final JobStatus status;
  final String? failed_reason;
  final String? post_url;

  const Job({
    required this.id,
    required this.platform_id,
    required this.text,
    required this.time,
    required this.status,
    this.failed_reason,
    this.post_url,
  });


  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      platform_id: json['platform_id'],
      text: json['text'],
      time: DateTime.parse(json['time']),
      status: JobStatus.values.firstWhere((e) => e.toString() == "JobStatus.${json['status']}"),
      failed_reason: json['failed_reason'],
      post_url: json['post_url'],
    );
  }

}

class JobsNotifier extends ChangeNotifier {
  List<Job> jobs = [];
  // loading is the initial state
  PageStatus status = PageStatus.loading;

  void addJob(Job job) {
    // TODO: implement posting text to server
    jobs.add(job);
    notifyListeners();
  }

  void loadJobs(BuildContext context) async {
    log("Loading jobs");

    status = PageStatus.loading;
    notifyListeners();
    // notify the page that we are loading it

    final pro = Provider.of<AuthNotifier>(context, listen: false);
    try {
      var resp = await http.get(
      Uri.parse("$API_PATH/jobs"),
      headers: {
        "Authorization": "Bearer ${pro.accessToken}"
      }
    );
    if (resp.statusCode == 401) {
      pro.signOut();
    } else if (resp.statusCode == 200) {
      var data = resp.body;
        var data_decoded = jsonDecode(data) as List<dynamic>;
        jobs = data_decoded.map((e) => Job.fromJson(e)).toList();
        status = PageStatus.loaded;
        notifyListeners();
      
      
    } else {
      log("Failed to load jobs: ${resp.body}");
      status = PageStatus.error;
      notifyListeners();
    }
    } catch (e) {
        log(e.toString());
        status = PageStatus.error;
        notifyListeners();
    }
    
  }
}