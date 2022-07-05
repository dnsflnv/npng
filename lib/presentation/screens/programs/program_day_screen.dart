import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:npng/data/models/models.dart';
import 'package:npng/data/repository.dart';
import 'package:npng/presentation/screens/programs/program_day_add_exercise.dart';
import 'package:npng/theme.dart';
import 'package:npng/widgets/change_int_field.dart';
import 'package:provider/provider.dart';
import 'package:npng/generated/l10n.dart';

class ProgramDayScreen extends StatefulWidget {
  const ProgramDayScreen({super.key, required this.day});
  final Day day;

  @override
  State<ProgramDayScreen> createState() => _ProgramDayScreenState();
}

class _ProgramDayScreenState extends State<ProgramDayScreen> {
  Map<int, bool> expanded = {};

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<Repository>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day.name as String),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProgramDayAddExercise(
                  day: widget.day,
                ),
              ),
            ).then((value) => setState(() {})),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Workout>>(
          stream: repository.findWorkoutByDay(widget.day.id as int),
          builder: (context, AsyncSnapshot<List<Workout>> snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final List<Workout> workouts =
                  (snapshot.hasData) ? [...snapshot.data!] : [];
              return ReorderableListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final item = workouts[index];
                  return Slidable(
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
                    key: ValueKey(item),
                    child: Column(
                      children: [
                        ExpansionTile(
                          onExpansionChanged: (value) =>
                              expanded[index] = value,
                          key: Key(index.toString()),
                          initiallyExpanded: expanded[index] ?? false,
                          tilePadding:
                              const EdgeInsets.only(right: 30.0, left: 16.0),
                          title: Text(
                            item.name as String,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          iconColor: Theme.of(context).primaryColor,
                          collapsedIconColor: Theme.of(context).primaryColor,
                          subtitle: Text(
                            item.description as String,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .bottomNavigationBarTheme
                                    .unselectedItemColor),
                          ),
                          children: [
                            Column(
                              children: [
                                Text(S.of(context).sets),
                                ChangeIntField(
                                  value: item.sets as int,
                                  decreaseCallback: () {
                                    if (item.sets as int > 1) {
                                      repository.updateWorkoutSetsRepeatsRest(
                                          item.copyWith(sets: item.sets! - 1));
                                    }
                                  },
                                  increaseCallback: () {
                                    repository.updateWorkoutSetsRepeatsRest(
                                        item.copyWith(sets: item.sets! + 1));
                                  },
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(S.of(context).repeats),
                                ChangeIntField(
                                  value: item.repeats as int,
                                  decreaseCallback: () {
                                    if (item.repeats as int > 1) {
                                      repository.updateWorkoutSetsRepeatsRest(
                                          item.copyWith(
                                              repeats: item.repeats! - 1));
                                    }
                                  },
                                  increaseCallback: () {
                                    repository.updateWorkoutSetsRepeatsRest(
                                        item.copyWith(
                                      repeats: item.repeats! + 1,
                                    ));
                                  },
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(S.of(context).rest),
                                ChangeIntField(
                                  value: item.rest as int,
                                  decreaseCallback: () {
                                    if (item.rest as int > 5) {
                                      repository.updateWorkoutSetsRepeatsRest(
                                          item.copyWith(rest: item.rest! - 5));
                                    }
                                  },
                                  increaseCallback: () {
                                    repository.updateWorkoutSetsRepeatsRest(
                                        item.copyWith(rest: item.rest! + 5));
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final Workout movedWorkout = workouts.removeAt(oldIndex);
                  workouts.insert(newIndex, movedWorkout);
                  repository.reorderWorkouts(workouts);
                  // There is no need to update state here.
                  // repository.reorderDays(days).then((value) {
                  //   setState(() {});
                  // });
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
