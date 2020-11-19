import 'package:bakecode_jobs/bakecode-jobs.dart';

class SandboxJob extends Node {
  @override
  Future<FlowContext> run(FlowContext context) async {
    Future.delayed(Duration(seconds: 10));

    return context;
  }
}
