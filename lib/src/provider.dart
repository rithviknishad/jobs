import 'package:bakecode_jobs/bakecode-jobs.dart';

abstract class Provider {
  static T of<T>(String property, FlowContext context, {Node forNode}) =>
      context['${forNode ?? ''}/$property'];
}
