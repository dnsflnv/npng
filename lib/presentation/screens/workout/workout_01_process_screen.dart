import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:npng/logic/cubit/workout_cubit.dart';
import 'package:npng/presentation/widgets/help_icon_button.dart';

import 'package:npng/data/models/models.dart';
import 'package:npng/data/repository.dart';
import 'package:npng/generated/l10n.dart';
import 'package:npng/presentation/screens/workout/workout_02_set_screen.dart';
import 'package:npng/presentation/screens/workout/workout_04_finish_screen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../theme.dart';
import '../../widgets/workout_exercise_settings.dart';
import 'program_day_add_exercise.dart';

/// Shows current workout program day (with exercises).
class WorkoutProcessScreen extends StatelessWidget {
  final Day? day;

  const WorkoutProcessScreen({super.key, this.day});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(day?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProgramDayAddExercise(
                  day: day!,
                ),
              ),
            ),
          ),
          HelpIconButton(help: S.of(context).hintWorkoutProcess),
        ],
      ),
      persistentFooterButtons: [
        Builder(
          builder: (context) {
            final activeValue = context.select(
                (WorkoutCubit workoutCubit) => workoutCubit.state.active);
            if (activeValue) {
              return const ActiveBottomBar();
            } else {
              return InitBottomBar(dayId: day?.id ?? 0);
            }
          },
        ),
      ],
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final activeValue = context.select(
                (WorkoutCubit workoutCubit) => workoutCubit.state.active);
            if (activeValue) {
              return const ActiveListView();
            } else {
              return InitListView(day: day);
            }
          },
        ),
      ),
    );
  }
}

/// Current workout before start.
class InitListView extends StatefulWidget {
  const InitListView({
    super.key,
    required this.day,
  });

  final Day? day;

  @override
  State<InitListView> createState() => _InitListViewState();
}

class _InitListViewState extends State<InitListView> {
  @override
  Widget build(BuildContext context) {
    Map<int, bool> expanded = {};
    final repository = context.read<Repository>();
    return StreamBuilder<List<Workout>>(
      stream: repository.findWorkoutByDay(widget.day?.id as int),
      builder: (context, AsyncSnapshot<List<Workout>> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final List<Workout> workouts =
              (snapshot.hasData) ? [...snapshot.data!] : [];
          if (workouts.isNotEmpty) {
            context.read<WorkoutCubit>().workoutsSnapshot = workouts;
          }
          return ReorderableListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final item = workouts[index];
              return Slidable(
                key: ValueKey(item),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        repository.deleteWorkout(item);
                        setState(() {});
                      },
                      backgroundColor: kActionColorDelete,
                      foregroundColor: kActionColorIcon,
                      icon: Icons.delete,
                      label: S.of(context).delete,
                    ),
                  ],
                ),
                child: WorkoutExerciseSettings(
                    index: index,
                    expanded: expanded,
                    item: item,
                    repository: repository),
              );
            },
            onReorder: (int oldIndex, int newIndex) {
              if (newIndex > oldIndex) newIndex -= 1;
              final Workout movedWorkout = workouts.removeAt(oldIndex);
              workouts.insert(newIndex, movedWorkout);
              repository.reorderWorkouts(workouts);
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

/// Shows active workout after start (workout in process).
class ActiveListView extends StatelessWidget {
  const ActiveListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: context.read<WorkoutCubit>().state.exercises.length,
      itemBuilder: (context, index) {
        return BlocBuilder<WorkoutCubit, WorkoutState>(builder: (_, state) {
          return ListTile(
              leading: (state.exercises[index].completed)
                  ? const Icon(
                      Icons.done,
                    )
                  : null,
              title: Text(state.exercises[index].name));
        });
      },
    );
  }
}

/// This bottom bar on workout init with start button.
class InitBottomBar extends StatelessWidget {
  final int dayId;

  const InitBottomBar({super.key, required this.dayId});

  @override
  Widget build(BuildContext context) {
    return Center(
      // Start button
      child: ElevatedButton(
        child: Text(S.of(context).start),
        onPressed: () {
          context.read<WorkoutCubit>().startWorkout(dayId);
          WakelockPlus.enable();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkoutSetScreen(),
            ),
          );
        },
      ),
    );
  }
}

/// This bottom bar for workout-in progress
class ActiveBottomBar extends StatelessWidget {
  const ActiveBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!context.read<WorkoutCubit>().state.finished)
          ElevatedButton(
            child: Text(S.of(context).ccontinue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutSetScreen(),
                ),
              );
            },
          ),
        const SizedBox(width: 16.0),
        ElevatedButton(
          child: Text(S.of(context).finish),
          onPressed: () {
            WakelockPlus.disable();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const WorkoutFinishScreen(),
              ),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
