import 'package:bakecode_jobs/bakecode-jobs.dart';

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
