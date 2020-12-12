import 'dart:async';

import 'package:bakecode/bakecode.dart';
import 'package:meta/meta.dart';

Future<void> main(List<String> args) => runFlow(MyRecipe());

class MyRecipe extends Flow {
  @override
  Flow run(FlowContext context) {
    return Recipe(
      name: 'MyRecipe',
      startsFrom: MyFlow(),
    );
  }
}

class MyFlow extends Flow {
  @override
  Flow run(FlowContext context) {
    return ParallelFlow(
      flows: [
        DelayedPrinterJob(),
        PrinterJob(),
      ],
      next: FlowBuilder(
        builder: (context) {
          print("OnComplete");
          return;
        },
      ),
    );
  }
}

class DelayedPrinterJob extends Flow {
  @override
  Flow run(FlowContext context) {
    return Delayed(
      duration: Duration(seconds: 2),
      next: PrinterJob(),
    );
  }
}

class Delayed extends Flow {
  final Duration duration;
  final Flow next;

  const Delayed({
    @required this.duration,
    @required this.next,
  });

  @override
  FutureOr<Flow> run(FlowContext context) async =>
      await Future.delayed(duration, () => next);
}

class PrinterJob extends Flow {
  @override
  FutureOr<Flow> run(FlowContext context) {
    print('Hello');
    return null;
  }
}
