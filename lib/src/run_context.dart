part of bakecode;

@immutable
class RunContext {
  final Map _data = {};

  RunContext() {
    set({
      'context id': hashCode,
      'created on': DateTime.now(),
    });
  }

  int? get contextID => this['context id'];

  DateTime? get createdOn => this['created on'];

  operator []=(key, value) => _data[key] = value;

  operator [](key) => _data[key];

  void set(Map entries) {
    assert(entries != null);
    _data.addAll(entries);
  }

  toString() => '$_data';
}
