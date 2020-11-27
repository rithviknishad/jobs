import 'package:bakecode_jobs/src/connection.dart';

import '../bakecode-jobs.dart';
import 'package:meta/meta.dart';

/// A connectable entity
abstract class Node {
  final _inputs = <InputConnection>[];

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
  Iterable<Node> get awaits => _inputs.map((node) => node.from);

  final _outputs = <OutputConnection>[];

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
  Iterable<Node> get next => _outputs.map((node) => node.to);

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
  bool get hasNext => _outputs.isEmpty == false;

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

  /// Updates the input state for [source] w/ the [context].
  ///
  /// After updating if [isReady] evaluates to true, [onReady] is invoked w/
  /// the provided [context].
  @nonVirtual
  void _receiveInput(Node source, FlowContext context) {
    disconnectFrom(source);

    if (isReady) {
      onReady.call(context);
    }
  }

  /// Whether every input nodes have finished and is ready to run.
  ///
  /// Evaluates to true if there are no nodes connected to the instance node,
  /// pending to finish.
  @nonVirtual
  bool get isReady => _inputs.isEmpty;

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
      return _outputs.firstWhere((connection) => connection.to == destination);

    var connection = Connection(from: this, to: destination);

    _outputs.add(connection);
    destination._inputs.add(connection);

    return connection;
  }

  @nonVirtual
  void disconnectFrom(Node source) {
    source._outputs.removeWhere((connection) => connection.to == this);
    _inputs.removeWhere((connection) => connection.from == source);
  }

  /// Connects the instance to every node in [destinations].
  ///
  /// The [destination] node will start awaiting for the instance node to be
  /// completed w/ a valid [FlowContext] for it's [onReady] to be triggered.
  @nonVirtual
  Iterable<Connection> connectToAll(Iterable<Node> destinations) =>
      destinations.map(connectTo);

  /// Completes the Node instance with [context] and informs every nodes in
  /// [next] about the updated [context].
  ///
  /// This method **must** be called after this Node's work so that nodes
  /// awaiting for this node to complete can know when completed.
  void _completeWith(FlowContext context) =>
      next.forEach((node) => node._receiveInput(this, context));

  /// The function that will be invoked once every connected to the instance
  /// node complete, i.e., when [isReady] evaluates to true.
  ///
  /// This method invokes [run] and then [completeWith] the updated [context] to
  /// finish the node's work.
  @nonVirtual
  @protected
  void onReady(FlowContext context) async {
    await run(context);
    _completeWith(context);
  }

  /// Executed by [onReady] when [isReady] evaluates to true.
  ///
  /// [context] shall be the [FlowContext] generated by [Flow.start].
  ///
  /// Make sure all updates to context are reflected on the [context] using
  /// [FlowContext.set] or [FlowContext.merge] for nested flow executions.
  @protected
  Future<void> run(FlowContext context);
}
