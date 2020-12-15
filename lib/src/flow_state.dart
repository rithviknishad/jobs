part of bakecode;

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
  /// resumed as the [_flowStateController] will be closed.
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
