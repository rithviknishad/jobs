import 'package:bakecode_jobs/bakecode-jobs.dart';
import 'package:meta/meta.dart';

@immutable
mixin InputConnection {
  Node get from;
}

@immutable
mixin OutputConnection {
  Node get to;
}

class Connection with InputConnection, OutputConnection {
  final Node from;
  final Node to;

  const Connection({@required this.from, @required this.to});
}
