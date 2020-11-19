import 'package:meta/meta.dart';

@immutable
class FlowContext {
  final Map<String, dynamic> data = {};

  FlowContext operator +(FlowContext context) =>
      this..data.addAll(context.data);

  operator [](String key) => data[key];

  toString() => """
  context_id: $contextID
  $data
  """;

  int get contextID => hashCode;
}
