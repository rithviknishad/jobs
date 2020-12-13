part of bakecode;

@immutable
abstract class Flow {
  const Flow();

  @protected
  FutureOr<Flow> run(RunContext context);
}

class FlowBuilder extends Flow {
  FlowBuilder({@required this.builder});

  @override
  FutureOr<Flow> run(RunContext context) => builder(context);

  final FutureOr<Flow> Function(RunContext context) builder;
}

class ParallelFlow extends Flow {
  const ParallelFlow({
    @required this.flows,
    this.next,
  });

  final Iterable<Flow> flows;
  final Flow next;

  Future<Flow> run(RunContext context) async {
    var subFlowControllers =
        flows.map((flow) => runSubFlow(flow: flow, parentContext: context));

    await Future.wait(subFlowControllers.map((controller) => controller.done));

    return next;
  }
}

class Recipe extends Flow {
  const Recipe({
    @required this.name,
    this.description,
    @required this.startsFrom,
  });

  final Flow startsFrom;

  final String name;

  final String description;

  @override
  FutureOr<Flow> run(RunContext context) {
    // TODO: implement run
    return startsFrom;
  }
}
