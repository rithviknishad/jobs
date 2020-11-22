import 'package:bakecode_jobs/bakecode-jobs.dart';

class Flow extends Node {
  Flow.startsFrom(Iterable<Node> startsFrom) : assert(startsFrom != null) {
    this.connectToAll(startsFrom);
  }

  factory Flow.startFrom(Node from) => Flow.startsFrom([from]);

  void start() => onReady(FlowContext());

  @override
  Future<void> run(FlowContext context) async {
    // TODO: add few about starting the flow here..
  }
}
