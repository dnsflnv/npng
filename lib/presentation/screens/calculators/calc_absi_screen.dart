import 'package:flutter/material.dart';
import 'package:npng/generated/l10n.dart';
import 'package:npng/logic/calculators/calc.dart';
import 'package:npng/logic/calculators/calc_absi.dart';
import 'package:npng/widgets/text_form_fields.dart';

class CalcAbsiScreen extends StatefulWidget {
  const CalcAbsiScreen({super.key});

  @override
  State<CalcAbsiScreen> createState() => _CalcAbsiScreenState();
}

class _CalcAbsiScreenState extends State<CalcAbsiScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController tcWeight = TextEditingController();
  TextEditingController tcHeight = TextEditingController();
  TextEditingController tcWaistCircumference = TextEditingController();
  TextEditingController tcAge = TextEditingController();
  late bool heightError = false;
  late bool weightError = false;
  late bool waistCircumferenceError = false;
  late bool ageError = false;

  double absi = 0;
  Sex sex = Sex.female;
  bool isUS = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).absiPageTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormFieldDouble(
                      tcWeight: tcWeight,
                      labelText: S.of(context).bmiWeight,
                      errorText: S.of(context).bmiWeightValidation,
                    ),
                    const SizedBox(height: 16),
                    TextFormFieldDouble(
                      tcWeight: tcHeight,
                      labelText: S.of(context).bmiHeight,
                      errorText: S.of(context).bmiHeightValidation,
                    ),
                    const SizedBox(height: 16),
                    TextFormFieldDouble(
                      tcWeight: tcWaistCircumference,
                      labelText: S.of(context).absiWaistCircumference,
                      errorText: S.of(context).absiWaistCircumferenceValidation,
                    ),
                    const SizedBox(height: 16),
                    TextFormFieldDouble(
                      tcWeight: tcAge,
                      labelText: S.of(context).age,
                      errorText: S.of(context).ageValidation,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(S.of(context).useImperialUS),
                      trailing: Switch(
                          value: isUS,
                          onChanged: (value) {
                            setState(() {
                              isUS = value;
                            });
                          }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Radio(
                          value: Sex.female,
                          groupValue: sex,
                          onChanged: (Sex? value) {
                            setState(() {
                              sex = value!;
                            });
                          },
                        ),
                        Text(S.of(context).female),
                        Radio(
                          value: Sex.male,
                          groupValue: sex,
                          onChanged: (Sex? value) {
                            setState(() {
                              sex = value!;
                            });
                          },
                        ),
                        Text(S.of(context).male),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: Text(S.of(context).calculate),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          double weight = double.parse(tcWeight.text);
                          double height = double.parse(tcHeight.text);
                          double waistCircumference =
                              double.parse(tcWaistCircumference.text);
                          int age = int.parse(tcAge.text);

                          if (isUS) {
                            weight = lbsToKg(weight);
                            height = inchToCm(height);
                            waistCircumference = inchToCm(waistCircumference);
                          }

                          CalcABSI calc = CalcABSI(
                              context: context,
                              weightAthlete: weight,
                              heightAthleteCm: height,
                              waistCircumferenceCm: waistCircumference,
                              gender: sex,
                              age: age);

                          absi = calc.absi;

                          String res = '''
# **ABSI:** ${absi.toStringAsFixed(5)}

**${S.of(context).absiMean}**: ${calc.absiMean.toStringAsFixed(5)}

**${S.of(context).absiRisk}**: ${calc.absiRisk}
'''; //

                          Navigator.pushNamed(context, '/result', arguments: {
                            'header': S.of(context).absiPageTitle,
                            'text': res,
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}