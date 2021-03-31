part of bakecode;

/// A controller for handling execution of [Flow]s.
class FlowController {
  /// Creates a flow controller that shall attempt to complete the top-level
  /// [flow].
  ///
  /// Use [runFlow] to bind a controller to the [flow] with a new [RunContext]
  /// and set [RunOptions].
  ///
  /// To use a controller inside a flow (use cases such as a sub-flow requiring
  /// a seperate [FlowController]), use [_runSubFlow], as [RunContext] can be
  /// inherited from parent flow's controller.
  /// For implementations of [_runSubFlow], see [ParallelFlow].
  FlowController({
    required Flow flow,
    RunContext? parentContext,
  })  : assert(flow != null),
        next = flow,
        context = parentContext ??
            RunContext() // TODO: RunContext(inheritFrom: parentContext)
  {
    // Listen to flow state updates.
    _flowStateController.stream.listen((newState) {
      if (state == newState) return;

      onStateChanged(newState);
    });

    // set this as the flow controller for the completer context.
    context.set({FlowController: this});
  }

  /// The [RunContext] of the flow completer to provide on invoking next flow's
  /// [Flow.run].
  @protected
  @nonVirtual
  RunContext context;

  /// The next flow that is to be completed by the flow completer.
  ///
  /// Can be null if the flow has been completed. However, may not be null if
  /// it was stopped before being able to complete.
  @protected
  @nonVirtual
  Flow? next;

  /// Whether diagnostics are enabled for this flow controller.
  ///
  /// If enabled / `true`, all flow controller activities will be reported
  /// as per configurations in [RunOptions].
  bool _diagnosticsEnabled = true;

  /// [StreamController] for the [FlowState] of this controller.
  final _flowStateController = StreamController<FlowState>();

  /// Holds the current [FlowState] of the controller.
  ///
  /// Initial [FlowState] of the controller is [FlowState.Paused].
  FlowState _state = FlowState.Paused;

  /// The sink of the [_flowStateController].
  Sink<FlowState> get _stateSink => _flowStateController.sink;

  /// The current [FlowState] of the controller.
  ///
  /// Initially the state is [FlowState.Paused], however by using [runFlow]
  /// which handles attaching of the controller to a flow, also calls
  /// [start] which causes to have [FlowState.Running].
  FlowState get state => _state;

  /// Whether the controller is running or not.
  ///
  /// If true, the controller is running, i.e., the controller is attempting
  /// to complete flow.
  ///
  /// If false, the controller is not running, i.e., the controller is not
  /// attempting to complete the remaining flow. This need not necessarily mean
  /// that the  controller is paused. It may also be [FlowState.Completed] or
  /// [FlowState.Stopped].
  ///
  /// See also:
  /// * [isPaused].
  /// * [isCompleted].
  /// * [isStopped].
  bool get isRunning => state == FlowState.Running;

  /// Whether the controller is paused or not.
  ///
  /// If true, the controller is paused, i.e., the controller is momentarily
  /// not attempting to complete the remaining flow, until [start] is invoked.
  ///
  /// If false, the controller is not paused. However, it may not necessarily
  /// mean it's running. It may also be [FlowState.Completed] or
  /// [FlowState.Stopped].
  ///
  /// See also:
  /// * [isRunning].
  /// * [isCompleted].
  /// * [isStopped].
  bool get isPaused => state == FlowState.Paused;

  /// Whether the controller is completed or not.
  ///
  /// If true, the controller has completed the flows and has achieved
  /// [FlowState.Completed] and **not**  [FlowState.Stopped].
  ///
  /// If false, the controller have not successfully completed yet. The
  /// controller may be running or is paused, or has stopped before being able
  /// to complete.
  ///
  /// See also:
  /// * [isRunning].
  /// * [isPaused].
  /// * [isStopped].
  bool get isCompleted => state == FlowState.Completed;

  /// Whether the controller is stopped or not.
  ///
  /// If true, the controller cannot attempt to complete the remaining flow.
  /// [stop] was called before the controller was able to complete all of the
  /// remaining flows.
  ///
  /// If false, the controller is not stopped and may be [isRunning] or
  /// [isPaused] or even [isCompleted].
  ///
  /// See also:
  /// * [isRunning].
  /// * [isPaused].
  /// * [isCompleted].
  bool get isStopped => state == FlowState.Stopped;

  /// Whether the controller is eligible to complete the remaining flow.
  ///
  /// Returns `true` if the controller can achieve or has achieved the state
  /// [FlowState.Completed], i.e., the controller has not been stopped
  /// (see [stop]), as the controller is eligible to complete the remaining
  /// flow as long as it's not stopped. The current state may or may not be
  /// [FlowState.Paused] or  [FlowState.Running] or even [FlowState.Completed].
  ///
  /// However, the getter returns `false` if the controller [isStopped].
  bool get canComplete => !isStopped;

  /// Whether the controller is eligible to run and attempt completing the
  /// remaining flow, i.e., calling [start] does not throw a [StateError].
  ///
  /// Returns `true` if the controller can achieve [FlowState.Running],
  /// [FlowState.Paused] or [FlowState.Completed] in the future, and has not
  /// completed yet. This means that the controller has not achieved neither
  /// the state [FlowState.Completed] nor [FlowState.Stopped] yet.
  ///
  /// Returns `false` if the controller has already completed or stopped, i.e.,
  /// it has already achieved the state [FlowState.Completed] or
  /// [FlowState.Stopped].
  bool get canRun => canComplete && !isCompleted;

  /// Whether the controller is eligible to be paused, i.e., calling [pause]
  /// does not throw a [StateError].
  ///
  /// Returns `true` if the controller can achieve [FlowState.Running],
  /// [FlowState.Paused] or [FlowState.Completed] in the future, and has not
  /// completed yet. This means that the controller has not achieved neither
  /// the state [FlowState.Completed] nor [FlowState.Stopped] yet.
  ///
  /// Returns `false` if the controller has already completed or stopped, i.e.,
  /// it has already achieved the state [FlowState.Completed] or
  /// [FlowState.Stopped].
  bool get canPause => canComplete && !isCompleted;

  /// Whether the controller is elligible to be stopped, i.e., calling [stop]
  /// does not throw [StateError].
  ///
  /// Returns `true` if the controller can achieve or has achieved the state
  /// [FlowState.Stopped]. This is possible only if the controller has not
  /// completed the flow, i.e., it has not achieved the state
  /// [FlowState.Completed] yet, even if its currently [FlowState.Stopped].
  bool get canStop => !isCompleted;

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
    if (!canRun) {
      throw StateError("Flow cannot be started when state == $state.");
    }

    _updateState(FlowState.Running);
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
    if (!canPause) {
      throw StateError("Flow cannot be paused when state == $state");
    }

    _updateState(FlowState.Paused);
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
    if (!canStop) {
      throw StateError("Flow cannot be stopped when state == $state");
    }

    _updateState(FlowState.Stopped);
  }

  /// Future that completes when the controller completes the flow or is
  /// stopped.
  ///
  /// If already completed, the future completes immediately.
  Future<void> get done => _ensureDone();

  /// Future that completes when the controller completes the flow or is
  /// stopped.
  ///
  /// If already completed, the future completes immediately.
  Future<void> _ensureDone() async {
    if (!canRun) return;

    await _flowStateController.done;
  }

  /// Attempts to recursively complete the flow while the [state] is
  /// [FlowState.Running].
  ///
  /// If [next] evaluates to `null`, [FlowState.Completed] will be acheived by
  /// the controller. After this state has been acheived, invoking [start],
  /// [pause] or [stop] can cause to throw [StateError].
  @protected
  @nonVirtual
  Future<void> complete() async {
    while (isRunning) {
      next = await next!.run(context);

      if (next == null) {
        _updateState(FlowState.Completed);
        break;
      }
    }
  }

  /// Updates the [FlowState] of the controller, by adding the state to the
  /// state controller's sink.
  @protected
  @nonVirtual
  void _updateState(FlowState state) => _stateSink.add(state);

  /// Invoked when there is a change in the [FlowState] of the controller.
  ///
  /// This function must call super at the very first if being overriden, so as
  /// to have the reflected state be accessible.
  @protected
  @mustCallSuper
  void onStateChanged(FlowState state) {
    _state = state;

    if (isRunning) {
      complete();
    }

    if (!canRun) {
      _stateSink.close();
    }
  }

  /// Gets the [FlowController] of a flow from it's [context].
  static FlowController? of(RunContext context) =>
      Provider.of<FlowController>(context);
}

/// Starts running the [flow].
///
/// Binds a [FlowController] to the [flow], sets the provided [RunOptions] and
/// invokes [FlowController.start].
FlowController runFlow(
  Flow flow, {
  bool diagnosticsEnabled = true,
}) =>
    FlowController(flow: flow)
      .._diagnosticsEnabled = diagnosticsEnabled
      ..start();

/// For sub-flows that require sharing of context, but with a seperate 
/// [FlowController], use [_runSubFlow].
/// 
/// Throws [MissingFlowControllerException] if there is no controller available
/// from the [parentContext].
/// 
/// [RunOptions] may be different from parent flow controller's run options, if
/// specified, else uses the same [RunOptions] as in the parent flow controller.
FlowController _runSubFlow({
  required Flow flow,
  required RunContext parentContext,
}) {
  final controller = FlowController.of(parentContext);

  if (controller == null) {
    throw MissingFlowControllerException(
        'No FlowController attached to parentContext. Skipping runSubFlow(...).');
  }

  return FlowController(flow: flow, parentContext: parentContext)
    .._diagnosticsEnabled = controller._diagnosticsEnabled
    ..start();
}
