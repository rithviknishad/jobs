import 'dart:async';

import 'package:bakecode/bakecode.dart';
import 'package:meta/meta.dart';

void main(List<String> args) => runFlow(MyRecipe());

class MyRecipe extends Flow {
  @override
  Flow run(RunContext context) {
    return Recipe(
      name: 'MyRecipe',
      startsFrom: MyFlow(),
    );
  }
}

class MyFlow extends Flow {
  @override
  Flow run(RunContext context) {
    return ParallelFlow(
      flows: [
        DelayedPrinterJob(),
        DelayedPrinterJob(),
        PrinterJob(),
      ],
      next: FlowBuilder(
        builder: (context) {
          print("OnComplete");
          return FlowBuilder(builder: (context) {
            print('onComplet2');
            return ParallelFlow(
              flows: [
                DelayedPrinterJob(),
                DelayedPrinterJob(),
                PrinterJob(),
              ],
              next: PrinterJob(),
            );
          });
        },
      ),
    );
  }
}

class DelayedPrinterJob extends Flow {
  @override
  Flow run(RunContext context) {
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
    required this.duration,
    required this.next,
  });

  @override
  FutureOr<Flow> run(RunContext context) async =>
      await Future.delayed(duration, () => next);
}

class PrinterJob extends Flow {
  @override
  FutureOr<Flow>? run(RunContext context) {
    print(hashCode);
    return null;
  }
}
