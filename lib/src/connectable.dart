import 'package:meta/meta.dart';

import '../bakecode-jobs.dart';

abstract class Connectable {
  /// All the input connections to the connectable instance.
  final _inputs = <InputConnection>[];

  /// All the output connections from the connectable instance.
  final _outputs = <OutputConnection>[];

  /// Iterable of all the [InputConnection]s to the [Connectable] instance.
  Iterable<InputConnection> get inputs => _inputs;

  /// Iterable of all the [OutputConnection]s from the connectable instance.
  Iterable<OutputConnection> get outputs => _outputs;

  /// [Connectable]s that have forward connection towards the connectable
  /// instance.
  ///
  /// *Example:*
  /// ```dart
  /// A.connectTo(C);
  /// B.connectTo(C);
  ///
  /// print(C.previous);
  /// ```
  /// Output: `[A, B]`
  Iterable<Connectable> get previous => inputs.map((input) => input.source);

  /// [Connectable]s that have forward connection from the connectable instance.
  ///
  /// *Example:*
  /// ```dart
  /// A.connectTo(B);
  /// A.connectTo(C);
  ///
  /// print(A.previous);
  /// ```
  /// Output: `[B, C]`
  Iterable<Connectable> get next => outputs.map((output) => output.destination);

  /// All [Connection]s associated with the connectable instance.
  ///
  /// Returns an iterable that concatenates the [inputs] and [outputs] of the
  /// connectable instance.
  ///
  /// The [Connection]s in the iterable either have [Connection.source] or
  /// [Connection.destination] as this connectable instance.
  Iterable<Connection> get connections =>
      inputs.cast<Connection>().followedBy(outputs);

  void _awaitFor(InputConnection source) {
    _inputs.add(source);

    source.stream.listen((context) {})
      ..onDone(() async {
        if (inputsClosed)
          onReady(await source.stream.last); // TODO: merge contexts...
      });
  }

  /// Whether every inputs are closed.
  ///
  /// Evaluates to true if every [InputConnection] in [inputs] evaluates to true
  /// for [InputConnection.isClosed].
  bool get inputsClosed => inputs.every((connection) => connection.isClosed);

  /// Connects the instance to [destination] and returns the [Connection].
  ///
  /// The returned [Connection] will have [Connection.source] as this instance
  /// and [Connection.destination] as [destination].
  ///
  /// The [destination] will start awaiting for this connectable instance to
  /// [completeWith] a valid [FlowContext] for it's [onReady] to be triggered.
  Connection connectTo(Connectable destination) {
    var connection = Connection(source: this, destination: destination);

    _outputs.add(connection);
    destination._awaitFor(connection);

    return connection;
  }

  /// The function that will be invoked once every [Connectable] in [previous]
  /// completes.
  ///
  /// Invoked when [inputsClosed] evaluates to true.
  @protected
  void onReady(FlowContext context);

  /// Completes the connectable instance with [context] and closes every
  /// [OutputConnection] in [outputs] after adding the [context] to it's sink.
  ///
  /// This method **must** be called after this connectable's work in order to
  /// close the connection. Only if all [OutputConnection]s closes the [next]
  /// [Connectables] will be able to start it's work.
  ///
  /// This method shall be invoked only by classes extending or mixin with this
  /// class.
  @nonVirtual
  @protected
  void completeWith(FlowContext context) {
    outputs.forEach((output) => output.sink
      ..add(context)
      ..close());
  }
}
