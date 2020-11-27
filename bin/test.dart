import 'dart:developer';

import 'package:bakecode_jobs/src/flow.dart';

import 'jobs.dart';

void main(List<String> args) async {
  var A = SandboxJob();
  var B = SandboxJob();
  var C = SandboxJob();
  var D = SandboxJob();
  var E = SandboxJob();

  A.connectToAll([B, C, D]);

  B.connectTo(E);
  C.connectTo(E);

  var flow = Flow(
    name: 'Sample',
    description: 'A sample flow lol',
    startsFrom: [A],
  );

  await flow.start();
}
