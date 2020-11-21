import 'package:bakecode_jobs/bakecode-jobs.dart';
import 'package:meta/meta.dart';

class Flow extends Connectable {
  final Connectable startsFrom;

  Flow({@required this.startsFrom}) : assert(startsFrom != null) {
    this.connectTo(startsFrom);
  }

  @override
  void onReady(FlowContext context) => completeWith(context);

  void start() => onReady(FlowContext());
}
