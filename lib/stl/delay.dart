import 'dart:async';

import 'package:bakecode_jobs/bakecode-jobs.dart';
import 'package:bakecode_jobs/src/provider.dart';

class DelayNode extends Node {
  @override
  String get name => 'Delay';

  @override
  String get description => "Delay by an amount";

  DelayNode(String uuid) : super(uuid);

  Future<void> run(FlowContext context) {
    final delay = Provider.of('$this.delay', context);

    return Future.delayed(
      Duration(seconds: delay),
    );
  }

  @override
  Map<String, Object> get props => {
        '$this.delayInSeconds': 0,
      };
}
