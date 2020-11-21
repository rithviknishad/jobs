import 'package:meta/meta.dart';

import '../bakecode-jobs.dart';

abstract class Connectable {
  final inputsState = <Connectable, FlowContext>{};

  /// All the output connections from the connectable instance.
  final next = <Connectable>[];

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
  // Iterable<Connectable> get next => outputs.map((output) => output.destination);

  void updateInputsState(FlowContext context, {@required Connectable source}) {
    inputsState[source] = context;

    if (isReady) {
      onReady(context);
    }
  }

  /// Whether every inputs are closed.
  ///
  /// Evaluates to true if every [InputConnection] in [inputs] evaluates to true
  /// for [InputConnection.isClosed].
  bool get isReady => inputsState.values.every((context) => context != null);

  /// Connects the instance to [destination] and returns the [Connection].
  ///
  /// The returned [Connection] will have [Connection.source] as this instance
  /// and [Connection.destination] as [destination].
  ///
  /// The [destination] will start awaiting for this connectable instance to
  /// [completeWith] a valid [FlowContext] for it's [onReady] to be triggered.
  void connectTo(Connectable destination) =>
      next.add(destination..inputsState[this] = null);

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
  void completeWith(FlowContext context) => next.forEach(
      (connectable) => connectable.updateInputsState(context, source: this));
}
