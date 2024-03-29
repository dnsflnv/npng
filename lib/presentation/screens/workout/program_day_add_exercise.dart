import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:npng/presentation/widgets/help_icon_button.dart';

import '../../../data/models/models.dart';
import '../../../data/repository.dart';
import '../../../generated/l10n.dart';

/// Add exercise to workout day screen.
/// [day]: day to add
class ProgramDayAddExercise extends StatefulWidget {
  final Day day;
  const ProgramDayAddExercise({super.key, required this.day});

  @override
  State<ProgramDayAddExercise> createState() => _ProgramDayAddExerciseState();
}

class _ProgramDayAddExerciseState extends State<ProgramDayAddExercise> {
  int selectedMuscle = -1;
  List<bool> selectedEx = [];

  @override
  Widget build(BuildContext context) {
    final repository =
        RepositoryProvider.of<Repository>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).pageAddEx),
        actions: [
          HelpIconButton(help: S.of(context).hintProgramsAddEx),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: StreamBuilder<List<Muscle>>(
                stream: repository.watchAllMuscles(),
                builder: (context, AsyncSnapshot<List<Muscle>> snapshot) {
                  //if (snapshot.connectionState == ConnectionState.active) {
                  final List<Muscle> muscles =
                      snapshot.hasData ? [...snapshot.data!] : [];
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Wrap(
                      clipBehavior: Clip.antiAlias,
                      spacing: 2.0,
                      runSpacing: 2.0,
                      children:
                          List<Widget>.generate(muscles.length, (int index) {
                        final item = muscles[index];
                        return ChoiceChip(
                          selected: (index == selectedMuscle) ? true : false,
                          label: Text(item.name as String),
                          onSelected: (bool selected) {
                            selectedMuscle = index;
                            setState(() {});
                          },
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Flexible(
              child: StreamBuilder(
                stream: repository.findExcersisesByMuscle(selectedMuscle),
                builder: (context, AsyncSnapshot<List<Exercise>> snapshotEx) {
                  final List<Exercise> exercises =
                      (snapshotEx.hasData) ? [...snapshotEx.data!] : [];
                  selectedEx = List<bool>.filled(exercises.length, false);
                  return ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final Exercise item = exercises[index];
                      return ListTile(
                        title: Text(item.name as String),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: () {
                            repository.insertWorkout(
                                widget.day.id as int, item.id as int);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).addEx),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
