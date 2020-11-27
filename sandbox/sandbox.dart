import 'dart:developer';

import 'package:bakecode_jobs/bakecode-jobs.dart';
import 'package:bakecode_jobs/src/flow.dart';

class SandboxJob extends Node {
  @override
  String get name => 'Sandbox Job';

  @override
  String get description => 'A sample sandbox job';

  @override
  String get uuid => '55ed263d-5257-4239-a6fd-43a9350d27aa';

  @override
  Future<void> run(FlowContext context) async {
    print('running $this');
    context.set({'$this deployed on': DateTime.now()});

    await Future.delayed(Duration(seconds: 3));

    print('completed $this');
    context.set({'$this completed on': DateTime.now()});
  }

  @override
  String toString() => '$name ($uuid/$hashCode)';
}

void main(List<String> args) {
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

  flow.start();
}
