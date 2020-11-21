import 'dart:developer';

import 'package:bakecode_jobs/src/flow.dart';

import 'jobs.dart';

void main(List<String> args) {
  var A = SandboxJob();
  var B = SandboxJob();
  var C = SandboxJob();
  var D = SandboxJob();

  print('A is ${A.hashCode}');
  print('B is ${B.hashCode}');
  print('C is ${C.hashCode}');
  print('D is ${D.hashCode}');

  A.connectTo(B);
  A.connectTo(C);

  B.connectTo(D);
  C.connectTo(D);

  Flow(startsFrom: A).start();
}
