import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:npng/presentation/screens/workout/program_new_day_screen.dart';

import '../../../data/models/models.dart';
import '../../../data/repository.dart';
import '../../../generated/l10n.dart';
import '../../../logic/cubit/default_program_cubit.dart';
import '../../../logic/cubit/workout_cubit.dart';
import '../../../theme.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/help_icon_button.dart';
import 'program_edit_day_screen.dart';
import 'workout_01_process_screen.dart';

/// This is the first screen of the workout (with days list).
class WorkoutCurrentProgramScreen extends StatelessWidget {
  const WorkoutCurrentProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DefaultProgramCubit, DefaultProgramState>(
      builder: (context, state) {
        final repository = context.read<Repository>();
        final program = repository.findProgram(
            state is DefaultProgramLoaded ? state.defaultProgram : 0);
        return FutureBuilder<Program>(
          future: program,
          builder: (context, snapshot) {
            return Scaffold(
              drawer: const BurgerMenu(),
              appBar: AppBar(
                title: Text((snapshot.hasData)
                    ? snapshot.data?.name as String
                    : S.of(context).currentProgram),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgramNewDayScreen(
                          programId:
                              (snapshot.hasData) ? snapshot.data?.id as int : 0,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/programs');
                    },
                    icon: const Icon(
                      Icons.folder_outlined,
                    ),
                  ),
                  HelpIconButton(help: S.of(context).hintWorkout),
                ],
              ),
              body: SafeArea(
                child: (context.watch<WorkoutCubit>().state.active)
                    ? const ArtiveWorkoutScreen()
                    : const DaysListWidget(),
              ),
            );
          },
        );
      },
    );
  }
}

class DaysListWidget extends StatefulWidget {
  const DaysListWidget({
    super.key,
  });

  @override
  State<DaysListWidget> createState() => _DaysListWidgetState();
}

class _DaysListWidgetState extends State<DaysListWidget> {
  @override
  Widget build(BuildContext context) {
    final repository = context.read<Repository>();

    return BlocBuilder<DefaultProgramCubit, DefaultProgramState>(
      builder: (context, state) {
        return StreamBuilder<List<Day>>(
          stream: repository.findDaysByProgram(
              state is DefaultProgramLoaded ? state.defaultProgram : 0),
          builder: (context, AsyncSnapshot<List<Day>> snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              // Because must be mutable for sorting
              final List<Day> days =
                  (snapshot.hasData) ? [...snapshot.data!] : [];
              if (days.isEmpty) {
                return Center(
                  child: ElevatedButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(S.of(context).selectProgram),
                        const SizedBox(width: 8),
                        const Icon(Icons.checklist_rounded),
                      ],
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/programs'),
                  ),
                );
              }

              return ReorderableListView.builder(
                onReorder: (int oldIndex, int newIndex) {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final Day movedDay = days.removeAt(oldIndex);
                  days.insert(newIndex, movedDay);
                  repository.reorderDays(days);
                },
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final item = days[index];
                  return Slidable(
                    key: ValueKey(item),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            repository.deleteDay(item.id ?? 0).then((value) {
                              if (value == false) {
                                SnackBar snackBar = SnackBar(
                                  content: Text(S.of(context).canNotDelDay),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            });
                          },
                          backgroundColor: kActionColorDelete,
                          foregroundColor: kActionColorIcon,
                          icon: Icons.delete,
                          label: S.of(context).delete,
                        ),
                        SlidableAction(
                          onPressed: (context) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProgramEditDayScreen(
                                day: item,
                              ),
                            ),
                          ).whenComplete(() => setState(() {})),
                          backgroundColor: kActionColorEdit,
                          foregroundColor: kActionColorIcon,
                          icon: Icons.edit,
                          label: S.of(context).edit,
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(item.name ?? ''),
                      subtitle: Text(item.description ?? ''),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutProcessScreen(
                            day: item,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }
}

/// Screen with button "Continue", if the workout is started.
class ArtiveWorkoutScreen extends StatelessWidget {
  const ArtiveWorkoutScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(S.of(context).workoutInProgress),
            const SizedBox(height: 20),
            ElevatedButton(
              child: Text(S.of(context).ccontinue),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutProcessScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
