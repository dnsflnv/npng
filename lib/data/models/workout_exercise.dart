import 'package:npng/data/models/workout_set.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
part 'workout_exercise.freezed.dart';
part 'workout_exercise.g.dart';

/// WorkoutExercise model generated by freezed package.
/// flutter pub run build_runner build --delete-conflicting-outputs
@freezed
class WorkoutExercise with _$WorkoutExercise {
  const factory WorkoutExercise({
    required int id,
    required String name,
    required int maxSets,
    required int restTime,
    required List<WorkoutSet> sets,
    required bool completed,
    required int limbs,
    required int bars,
    required int loadId,
  }) = _WorkoutExercise;

  factory WorkoutExercise.fromJson(Map<String, Object?> json) =>
      _$WorkoutExerciseFromJson(json);
}
