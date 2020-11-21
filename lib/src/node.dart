import '../bakecode-jobs.dart';
import 'package:meta/meta.dart';

/// A connectable element.
abstract class Node extends Connectable {
  @override
  @nonVirtual
  @protected
  void onReady(FlowContext context) async {
    await run(context);
    completeWith(context);
  }

  /// Executed when [receivedAll] evaluates to true.
  ///
  /// The returned [FlowContext] is added to the [output]'s sink
  /// External invocation shall not be performed. This function is automatically
  /// invoked when every [InputConnection] in [inputs] closes.
  @protected
  Future<void> run(FlowContext context);
}
