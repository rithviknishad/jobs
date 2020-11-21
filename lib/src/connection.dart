import 'dart:async';

import '../bakecode-jobs.dart';
import 'package:meta/meta.dart';

/// This asbtract class gives access to the stream of the [Connection].
@immutable
abstract class InputConnection {
  /// The listenable stream of the [Connection._flow].
  Stream<FlowContext> get stream;

  /// Whether the connection is closed.
  bool get isClosed;

  Connectable get source;

  @override
  String toString() => 'InputConnection(source: $source)';
}

/// This abstract class presents functionalities to connect the output to
/// another node gives access to the sink of the [Connection].
@immutable
abstract class OutputConnection {
  /// The sink of the [Connection._flow].
  Sink<FlowContext> get sink;

  Connectable get destination;

  @override
  String toString() => 'OutputConnection(destination: $destination)';
}

/// The element that links multiple [Node]s.
@immutable
class Connection with InputConnection, OutputConnection {
  final _flow = StreamController<FlowContext>();

  final Connectable source, destination;

  Connection({@required this.source, @required Connectable this.destination})
      : assert(source != null),
        assert(destination != null);

  @override
  bool get isClosed => _flow.isClosed;

  @override
  Sink<FlowContext> get sink => _flow.sink;

  @override
  Stream<FlowContext> get stream => _flow.stream.asBroadcastStream();

  @override
  String toString() => 'Connection(source: $source, destination: $destination)';
}
