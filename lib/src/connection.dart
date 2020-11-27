import 'dart:async';

import 'package:bakecode_jobs/bakecode-jobs.dart';
import 'package:meta/meta.dart';

@immutable
mixin InputConnection {
  Node get source;

  Stream<FlowContext> get stream;
}

@immutable
mixin OutputConnection {
  Node get destination;

  Sink<FlowContext> get sink;
}

class Connection with InputConnection, OutputConnection {
  final Node source, destination;

  @protected
  @nonVirtual
  final flowController = StreamController<FlowContext>();

  Connection({@required this.source, @required this.destination});

  @override
  Stream<FlowContext> get stream => flowController.stream;

  @override
  Sink<FlowContext> get sink => flowController.sink;

  @override
  String toString() => 'Connection(from: $source, to: $destination)';
}
