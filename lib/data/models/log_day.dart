import 'package:freezed_annotation/freezed_annotation.dart';
part 'log_day.freezed.dart';
part 'log_day.g.dart';

/// Log day model generated by freezed package.
/// flutter pub run build_runner build --delete-conflicting-outputs
@freezed
class LogDay with _$LogDay {
  factory LogDay({
    int? logDayId,
    int? dayId,
    String? start,
    String? finish,
    String? daysName,
    String? programsName,
  }) = _LogDay;

  factory LogDay.fromJson(Map<String, Object?> json) => _$LogDayFromJson(json);
}
