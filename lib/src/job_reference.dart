import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Represent a reference to a BakeCode Job.
///
///
@immutable
class JobReference extends Equatable {
  /// The ID that represents the job.
  final String id;

  /// Create a reference to a job from the job id as String.
  const JobReference.fromID(this.id) : assert(id != null);

  get props => [id];

  toString() => id;
}
