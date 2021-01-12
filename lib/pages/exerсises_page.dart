import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multiplatform_widgets/multiplatform_widgets.dart';
import 'package:npng/generated/l10n.dart';
import 'package:npng/models/musles_model.dart';
import 'package:npng/pages/exercises_by_muscle_page.dart';
import 'dart:io' show Platform;
import 'package:npng/services/db.dart';

class ExercisesPage extends StatefulWidget {
  static String id = 'exersises';

  @override
  _ExercisesPageState createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  List<MusclesItem> _musles = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() async {
    List<Map<String, dynamic>> _results = await DB.query(MusclesItem.table);

    _musles = _results.map((item) => MusclesItem.fromMap(item)).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MpScaffold(
      appBar: MpAppBar(
        title: Text('Exersises'),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: ListView.builder(
            itemCount: _musles.length,
            itemBuilder: (context, index) {
              final item = _musles[index];
              return MpListTile(
                title: Text(item.name),
                onTap: () {
                  Navigator.push(
                    context,
                    mpPageRoute(
                      builder: (context) {
                        return ExercisesByMusclePage(
                          musclesId: item.id,
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        items: [
          TabItem(icon: Icons.list, title: "Train"),
          TabItem(icon: Icons.calendar_today, title: "Measure"),
          TabItem(icon: Icons.assessment, title: "Stats"),
          TabItem(icon: Icons.assessment, title: "Exercises"),
        ],
        initialActiveIndex: 3,
        // ignore: todo
        //TODO: Make settings provider.
        backgroundColor: (!kIsWeb && (Platform.isMacOS || Platform.isIOS))
            ? CupertinoTheme.of(context).barBackgroundColor
            : Theme.of(context).backgroundColor,
        onTap: (int i) => print('click index=$i'),
      ),
    );
  }
}
