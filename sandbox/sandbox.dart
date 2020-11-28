import 'dart:developer';

import 'package:bakecode_jobs/bakecode-jobs.dart';
import 'package:bakecode_jobs/src/flow.dart';

class SandboxJob extends Node {
  @override
  String get name => 'Sandbox Job';

  @override
  String get description => 'A sample sandbox job';

  SandboxJob(String uuid) : super(uuid);

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
  var A = SandboxJob('fe34a57f-53a1-4233-b2f0-8d3e1fdea56f');
  var B = SandboxJob('f6351978-74f9-4e79-afa9-5de1c6c15d6e');
  var C = SandboxJob('1a30f99a-14b4-4033-a761-6b8536e31efa');
  var D = SandboxJob('2bdb4eaa-eb97-463a-ab86-7510d857979c');
  var E = SandboxJob('14b59060-4147-443d-a51e-c7330f699002');

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
