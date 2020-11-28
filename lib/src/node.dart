import 'dart:async';

import 'package:bakecode_jobs/bakecode-jobs.dart';
import 'package:bakecode_jobs/src/connection.dart';
import 'package:meta/meta.dart';

/// A connectable [FlowContext] process entity.
abstract class Node {
  /// The name of the node.
  String get name;

  /// Description of the node.
  ///
  /// Implement this to give a gist about what this does does, and expects from
  /// the [FlowContext].
  String get description;

  /// UUID generated by bake program after certification.
  @nonVirtual
  final String uuid;

  /// Node constructor.
  ///
  /// [uuid] shall be given to instantiate the node in a flow.
  Node(this.uuid);

  @protected
  @nonVirtual
  final inputs = <InputConnection, FlowContext>{};

  /// [Node]s that have forward connection to the instance node.
  ///
  /// *Example:*
  /// ```dart
  /// B.connectTo(D);
  /// C.connectTo(D);
  ///
  /// print(D.awaits);
  /// ```
  /// Output: `[B, C]`
  @nonVirtual
  Iterable<Node> get awaits => inputs.keys.map((node) => node.source);

  void await(InputConnection connection) {
    inputs[connection] = null;

    connection.stream.listen((context) {
      inputs[connection] = context;
      if (isReady) {
        onReady.call(context);
      }
    });
  }

  @protected
  @nonVirtual
  final outputs = <OutputConnection>[];

  /// [Node]s that have forward connection from the instance node.
  ///
  /// *Example:*
  /// ```dart
  /// A.connectTo(B);
  /// A.connectTo(C);
  ///
  /// print(A.next);
  /// ```
  /// Output: `[B, C]`
  @nonVirtual
  Iterable<Node> get next => outputs.map((node) => node.destination);

  /// Whether the instance node is further connected to another node.
  ///
  /// *Example:*
  /// ```dart
  /// A.connectTo(B);
  ///
  /// // will have:
  /// A.hasNext == true;
  /// B.hasNext == false;
  /// ```
  @nonVirtual
  bool get hasNext => outputs.isEmpty == false;

  /// Recursively finds the end nodes for the instance node.
  ///
  /// **Note:** Returned iterable may contain duplicates of a same node, and
  /// can be removed by
  /// ```dart
  /// ...endsAt.toSet();
  /// ```
  ///
  /// If no node is there in [next], the instance node is returned.
  ///
  /// *Example:*
  /// ```dart
  /// var flow = Flow.startFrom(A
  ///   ..connectToAll(
  ///     [
  ///       B..connectTo(E),
  ///       C..connectTo(E),
  ///       D,
  ///     ],
  ///   ));
  ///
  /// print(flow.endsAt);
  /// print(flow.endsAt.toSet());
  /// ```
  ///
  /// *Output:*
  /// ```dart
  /// [D, E, E]
  /// {D, E}
  /// ```
  @nonVirtual
  Iterable<Node> get endsAt => (hasNext
      ? next.map((n) => n.endsAt).reduce((a, b) => a.followedBy(b))
      : [this]);

  /// Whether every input nodes have finished and is ready to run.
  ///
  /// Evaluates to true if there are no nodes connected to the instance node,
  /// pending to finish.
  @nonVirtual
  bool get isReady => inputs.values.contains(null) == false;

  /// Whether the instance node is connected or not to the [destination] node.
  ///
  /// Returns true if [next] contains the [destination] node, else false.
  @nonVirtual
  bool isConnectedTo(Node destination) => next.contains(destination);

  /// Connects the instance node to the [destination] node.
  ///
  /// The connection made will be a **forward connection**. i.e.,
  /// ```dart
  /// A.connectTo(B);
  /// ```
  /// makes a forward connection from node `A` to node `B`. Or in other words
  /// `B`'s [onReady] will be invoked only after `A`'s [completeWith] is
  /// invoked.
  ///
  /// The [destination] node will start awaiting for the instance node to be
  /// completed w/ a valid [FlowContext] for it's [onReady] to be triggered.
  ///
  /// Returns the [Connection] instance that connects the instance node and
  /// [destination] node.
  @nonVirtual
  Connection connectTo(Node destination) {
    if (isConnectedTo(destination))
      return outputs.firstWhere((c) => c.destination == destination);

    var connection = Connection(source: this, destination: destination);

    outputs.add(connection);
    destination.await(connection);

    return connection;
  }

  /// Connects the instance to every node in [destinations].
  ///
  /// The [destination] node will start awaiting for the instance node to be
  /// completed w/ a valid [FlowContext] for it's [onReady] to be triggered.
  @nonVirtual
  Iterable<Connection> connectToAll(Iterable<Node> destinations) =>
      destinations.map(connectTo).toList();

  /// The function that will be invoked once every node connected to the
  /// instance node completes, i.e., when [isReady] evaluates to true.
  ///
  /// This method invokes [run] and then informs every nodes in [next] about the
  /// updated [context].
  @nonVirtual
  @protected
  void onReady(FlowContext context) async {
    await run(context);
    outputs.forEach((output) => output.sink.add(context));
  }

  /// Executed by [onReady] when [isReady] evaluates to true.
  ///
  /// [context] shall be the [FlowContext] generated by [Flow.start].
  ///
  /// Make sure all updates to context are reflected on the [context] using
  /// [FlowContext.set] or [FlowContext.merge] for nested flow executions.
  @protected
  FutureOr run(FlowContext context);

  @override
  String toString() => '$hashCode';
}
