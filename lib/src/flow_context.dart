import 'package:meta/meta.dart';

@immutable
class FlowContext {
  final Map<String, dynamic> _data = {};

  FlowContext() {
    set({
      'context id': hashCode,
      'created on': DateTime.now(),
    });
  }

  int get contextID => this['context id'];

  DateTime get createdOn => this['created on'];

  operator []=(String key, dynamic value) => _data[key] = value;

  operator [](String key) => _data[key];

  void set(Map entries) => _data.addAll(entries);

  toString() => '$_data';
}
