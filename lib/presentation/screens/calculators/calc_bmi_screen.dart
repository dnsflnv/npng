import 'package:flutter/material.dart';
import 'package:npng/generated/l10n.dart';
import 'package:npng/logic/calculators/calc.dart';
import 'package:npng/logic/calculators/calc_bmi.dart';
import 'package:npng/presentation/widgets/text_form_fields.dart';

class CalcBmiScreen extends StatefulWidget {
  const CalcBmiScreen({super.key});

  @override
  State<CalcBmiScreen> createState() => _CalcBmiScreenState();
}

class _CalcBmiScreenState extends State<CalcBmiScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController tcWeight = TextEditingController();

  TextEditingController tcHeight = TextEditingController();

  double bmi = 0;
  String result = '';
  bool isUS = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).bmiPageTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormFieldDouble(
                        tcValue: tcWeight,
                        labelText: S.of(context).bmiWeight,
                        errorText: S.of(context).bmiWeightValidation,
                      ),
                      const SizedBox(height: 16),
                      TextFormFieldDouble(
                        tcValue: tcHeight,
                        labelText: S.of(context).bmiHeight,
                        errorText: S.of(context).bmiHeightValidation,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        child: Text(S.of(context).calculate),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            double weight = double.parse(tcWeight.text);
                            double height = double.parse(tcHeight.text);

                            if (isUS) {
                              weight = lbsToKg(weight);
                              height = inchToCm(height);
                            }

                            CalculatorBmi calc = CalculatorBmi(
                                context: context,
                                weightAthlete: weight,
                                heightAthleteCm: height);

                            bmi = calc.bmi();
                            result = calc.bmiInterpretation();

                            String res = '''
# **${S.of(context).bmi}:** ${bmi.toStringAsFixed(3)}
$result''';

                            Navigator.pushNamed(
                              context,
                              '/result',
                              arguments: {
                                'header': S.of(context).bmi,
                                'text': res,
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
