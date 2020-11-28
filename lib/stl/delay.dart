import 'dart:async';

import 'package:bakecode_jobs/bakecode-jobs.dart';

class DelayNode extends Node {
  @override
  String get name => 'Delay';

  @override
  String get description => "Delay by an amount";

  DelayNode(String uuid) : super(uuid);

  run(FlowContext context) => Future.delayed(
      Duration(seconds: context['$this.durationInSeconds'] as int));
}
