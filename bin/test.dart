import 'jobs.dart';

void main(List<String> args) {
  var A = SandboxJob();
  var B = SandboxJob();
  var C = SandboxJob();
  var D = SandboxJob();

  print('A is ${A.hashCode}');
  print('B is ${B.hashCode}');
  // print('C is ${C.hashCode}');
  print('D is ${D.hashCode}');
}
