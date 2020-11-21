import 'package:bakecode_jobs/bakecode-jobs.dart';
import 'package:meta/meta.dart';

class Flow extends Node {
  Flow({@required Iterable<Node> startsFrom}) : assert(startsFrom != null) {
    this.connectToAll(startsFrom);
  }

  void start() => onReady(FlowContext());

  @override
  Future<void> run(FlowContext context) async {
    // TODO: add few about starting the flow here..
  }
}
