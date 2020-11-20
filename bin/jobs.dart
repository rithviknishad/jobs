import 'package:bakecode_jobs/bakecode-jobs.dart';

class SandboxJob extends Node {
  @override
  Future<FlowContext> run(FlowContext context) async {
    await Future.delayed(Duration(seconds: 2));

    return context
      ..set({
        'SandBoxJob-$hashCode completed on': DateTime.now(),
      });
  }
}
