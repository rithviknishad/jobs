part of bakecode;

abstract class Provider {
  static T of<T>(FlowContext context) => context[T];
}
