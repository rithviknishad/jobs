import 'package:jobs/src/connection.dart';
import 'package:jobs/src/flow_context.dart';
import 'package:meta/meta.dart';

// TODO: add progress awaition for flowcontext specials... make use of listen.onDone callback
/// A connectable element.
abstract class Node {
  /// Contains the received [FlowContext] for every [InputConnection] connected
  /// to the instance node.
  ///
  /// [inputContexts.values] can contain null if a [FlowContext] was not
  /// received from an [InputConnection] in [inputs].
  final inputContexts = <InputConnection, FlowContext>{};

  /// Every [InputConnection]s the instance node awaits to complete.
  Iterable<InputConnection> get inputs => inputContexts.keys;

  /// The [OutputConnection] of the instance node.
  ///
  /// The returned [FlowContext] is added to output's sink and the [Connection]
  /// closes once [run] has successfully completed.
  final OutputConnection output = Connection();

  /// Returns the list of [Node]s that awaits the instance node.
  ///
  /// Looks up [output] connection of the instance node and returns
  /// [Connection.awaiters].
  List<Node> get nextNodes => (output as Connection).awaiters;

  /// Evaluates to true if received a [FlowContext] from every [inputs] of the
  /// instance node else false.
  ///
  /// Checks if [inputContexts.values] contains null. [inputContexts.values]
  /// is null if a [FlowContext] was not received from an [InputConnection] in
  /// [inputs].
  bool get receivedAll => inputContexts.values.contains(null) == false;

  /// Start's listening to [input] for [FlowContext].
  ///
  /// Start's awaiting [input] to send [FlowContext].
  @protected
  @nonVirtual
  void await(InputConnection input) {
    inputContexts[input] = null;

    input.stream.listen(
      (context) => inputContexts[input] = context,
      onDone: () async {
        if (receivedAll) {
          output.sink
            ..add(await run(FlowContext.merge(inputContexts.values)))
            ..close();
        }
      },
      // TODO: add onError using connection.addError => _flow.addError,
      // allow these to be custom defined too.
      cancelOnError: true,
    );
  }

  /// Connects the instance node to the specified [node].
  ///
  /// For `A` as the instance node and `B` as the specified [node],
  /// ```dart
  /// A.connectTo(B);
  /// ```
  /// makes a new **forward connection** from `A` to `B`, such that `B` listens
  /// to `A`'s [output] connection.
  ///
  /// To make a forward conection to multiple nodes, use [connectToAll].
  @nonVirtual
  void connectTo(Node node) =>
      output.connectTo(node..await(output as InputConnection));

  /// Connects the instance node to every [Node] in [nodes].
  ///
  /// For `A` as the instance node and [nodes] as a collection of [Node]s,
  /// ```dart
  /// A.connectToAll(nodes);
  /// ```
  /// makes a new **forward connection** from `A` to every node in [nodes],
  /// such that every [Node] in [nodes] listens to `A`'s [output] connection.
  ///
  /// To make a forward conection to a single node, use [connectTo].
  @nonVirtual
  void connectToAll(List<Node> nodes) => nodes.map(connectTo);

  /// Executed when [receivedAll] evaluates to true.
  ///
  /// The returned [FlowContext] is added to the [output]'s sink
  /// External invocation shall not be performed. This function is automatically
  /// invoked when every [InputConnection] in [inputs] closes.
  @protected
  Future<FlowContext> run(FlowContext context);
}
