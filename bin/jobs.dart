import 'package:bakecode_jobs/bakecode-jobs.dart';

class SandboxJob extends Node {
  @override
  Future<void> run(FlowContext context) async {
    print('running $hashCode w/ context: $context.');

    context.set({'$hashCode deployed on': DateTime.now()});

    await Future.delayed(Duration(seconds: 3));
    print('running $hashCode completed.');

    context.set({'$hashCode finished on': DateTime.now()});
  }

  toString() => '$hashCode';
}
