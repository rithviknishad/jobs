import 'dart:developer';

import 'package:bakecode_jobs/src/flow.dart';

import 'jobs.dart';

void main(List<String> args) {
  var A = SandboxJob();
  var B = SandboxJob();
  var C = SandboxJob();
  var D = SandboxJob();
  var E = SandboxJob();

  var flow = Flow.startFrom(A
    ..connectToAll(
      [
        B..connectTo(E),
        C..connectTo(E),
        D,
      ],
    ));

  flow.start();
}
