import 'dart:async';

import 'package:bakecode_jobs/bakecode-jobs.dart';
import 'package:meta/meta.dart';

class Flow extends Node {
  final String name;

  final String description;

  Flow({
    @required this.name,
    @required this.description,
    @required Iterable<Node> startsFrom,
  }) : super('e9e2e926-434c-4f25-9262-7fdfed7153d7') {
    this.connectToAll(startsFrom);
  }

  @override
  FutureOr run(FlowContext context) {
    print('Starting flow: $this');
  }

  void start(FlowContext context) => onReady(context);

  @override
  Map<String, Object> get props => {};
}
