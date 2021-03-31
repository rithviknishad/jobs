part of bakecode;

abstract class Provider {
  static T? of<T>(RunContext context) => context[T];
}
