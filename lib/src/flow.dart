part of bakecode;

@immutable
abstract class Flow {
  const Flow();

  @protected
  FutureOr<Flow> run(FlowContext context);
}

/// The possible states of a [FlowController].
enum FlowState {
  /// The state in which the [FlowController] attempts to complete the pending
  /// flow.
  ///
  /// This state can be achieved by invoking [FlowController.start].
  /// However if the controller has completed or stopped already, invoking
  /// [FlowController.start] can cause to throw a [StateError].
  Running,

  /// The state in which the [FlowController] has been paused, and shall not
  /// attempt to complete the pending flow unless [FlowController.start] is
  /// invoked.
  ///
  /// This state can be achieeved by invoking [FlowController.pause].
  /// However if the controller has completed or stopped already, invoking
  /// [FlowController.start] can cause to throw a [StateError].
  Paused,

  /// The state in which the [FlowController] shall no longer attempt to
  /// complete the pending flow.
  ///
  /// This state is used when the flow is required to terminate before being
  /// able to complete. Once this state is achieved, Flow execution cannot be
  /// resumed as the [_flowStateStreamController] will be closed.
  ///
  /// Invoking [FlowController.start] or [FlowController.pause] in this state
  /// can cause to throw a [StateError].
  Stopped,

  /// The state in which the [FlowController] has completed the flow.
  ///
  /// Once this state is achieved, invoking [FlowController.start],
  /// [FlowController.pause] or [FlowController.stop] can cause to throw a
  /// [StateError].
  Completed,
}

/// A controller for handling execution of [Flow]s.
class FlowController {
  /// [StreamController] for the [FlowState] of this controller.
  final _flowStateStreamController = StreamController<FlowState>();

  /// The sink of the [_flowStateStreamController].
  Sink<FlowState> get _stateSink => _flowStateStreamController.sink;

  /// Holds the current [FlowState] of the controller.
  FlowState _currentState;

  /// The current [FlowState] of the controller.
  FlowState get currentState => _currentState;

  /// Starts or resumes the flow completer.
  ///
  /// Attempts to change the current flow state to [FlowState.Running].
  /// After this function has successfully completed, the [FlowController] shall
  /// attempt to complete the pending flow.
  ///
  /// If the flow has already completed or stopped, invoking this function can
  /// throw [StateError].
  @nonVirtual
  void start() {
    if (currentState == FlowState.Stopped ||
        currentState == FlowState.Completed) {
      throw StateError(
          "Flow cannot be started when currentState == $currentState.");
    }

    _stateSink.add(FlowState.Running);
  }

  /// Pauses the flow completer until [start] is invoked.
  ///
  /// Attempts to change the current flow state to [FlowState.Paused].
  /// After this function has successfully completed, the [FlowController] shall
  /// not attempt to complete the pending flow, unless [start] is invoked.
  ///
  /// If the flow has already completed or stopped, invoking this function can
  /// throw [StateError].
  @nonVirtual
  void pause() {
    if (currentState == FlowState.Stopped ||
        currentState == FlowState.Completed) {
      throw StateError(
          "Flow cannot be paused when currentState == $currentState");
    }

    _stateSink.add(FlowState.Paused);
  }

  /// Stops the flow completer from completing the flow forever.
  ///
  /// Attempts to change the current flow state to [FlowState.Stopped].
  /// After this function has successfully completed. the [FlowController] shall
  /// not anymore attempt to complete the pending flow. Completion of the
  /// pending flow cannot be resumed by invoking [start] as it can throw
  /// [StateError].
  ///
  /// If the flow has already completed, invoking this function can throw
  /// [StateError].
  @nonVirtual
  void stop() {
    if (currentState == FlowState.Completed) {
      throw StateError(
          "Flow cannot be stopped when currentState == $currentState");
    }

    _stateSink.add(FlowState.Stopped);
  }

  Future<void> get done => _ensureDone();

  Future<void> _ensureDone() async {
    if (currentState == FlowState.Completed ||
        currentState == FlowState.Stopped) return;

    await _flowStateStreamController.done;

    return;
  }

  /// The next flow that is to be completed.
  @protected
  @nonVirtual
  Flow _next;

  /// The flow context for the flow completer to provide on invoking [Flow.run].
  final FlowContext context;

  /// Attempts to recursively complete the flow while the [currentState] is
  /// [FlowState.Running].
  ///
  /// If [_next] evaluates to `null`, [FlowState.Completed] will be acheived by
  /// the controller. After this state has been acheived, invoking [start],
  /// [pause] or [stop] can cause to throw [StateError].
  @protected
  @nonVirtual
  Future<void> complete() async {
    while (currentState == FlowState.Running) {
      _next = await _next.run(context);

      if (_next == null) {
        _stateSink.add(FlowState.Completed);
        return;
      }
    }
  }

  /// Updates the flow [state] of the controller.
  @protected
  @nonVirtual
  void updateState(FlowState state) {
    _currentState = state;

    if (state == FlowState.Running) {
      complete();
    }

    if (state == FlowState.Completed) {
      _stateSink.close();
    }
  }

  /// Creates a flow controller to handle the completion of a top-level flow.
  FlowController({@required Flow flow})
      : assert(flow != null),
        _next = flow,
        context = FlowContext() {
    // Listen to flow state updates.
    _flowStateStreamController.stream.listen(updateState);

    // set this as the flow controller for the completer context.
    context.set({FlowController: this});
  }

  /// Gets the [FlowController] of the [context].
  static FlowController of(FlowContext context) =>
      Provider.of<FlowController>(context);
}
