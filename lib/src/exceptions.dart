part of bakecode;

class MissingFlowControllerException implements Exception {
  final String message;

  const MissingFlowControllerException(this.message);

  @override
  String toString() => 'MissingFlowControllerException: $message';
}
