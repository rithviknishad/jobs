import '../bakecode-jobs.dart';
import 'package:meta/meta.dart';

/// A connectable element.
abstract class Node extends Connectable {
  @override
  @nonVirtual
  @protected
  void onReady(FlowContext context) async => completeWith(await run(context));

  /// Executed when [receivedAll] evaluates to true.
  ///
  /// The returned [FlowContext] is added to the [output]'s sink
  /// External invocation shall not be performed. This function is automatically
  /// invoked when every [InputConnection] in [inputs] closes.
  @protected
  Future<FlowContext> run(FlowContext context);
}
