import 'package:bakecode_jobs/bakecode-jobs.dart';
import 'package:meta/meta.dart';

class Flow extends Node {
  final String name;

  final String description;

  Flow({
    @required this.name,
    @required this.description,
    @required Iterable<Node> startsFrom,
  }) {
    this.connectToAll(startsFrom);
  }

  Future<void> start() => onReady(FlowContext());

  @override
  Future<void> run(FlowContext context) async {
    // TODO: add few about starting the flow here..
  }

  @override
  String get uuid => 'e9e2e926-434c-4f25-9262-7fdfed7153d7';
}
