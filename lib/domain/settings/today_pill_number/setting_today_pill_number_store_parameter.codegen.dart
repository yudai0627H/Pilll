import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pilll/entity/pill_sheet.codegen.dart';
import 'package:pilll/entity/pill_sheet_group.codegen.dart';
import 'package:pilll/entity/setting.codegen.dart';

part 'setting_today_pill_number_store_parameter.codegen.freezed.dart';

@freezed
class SettingTodayPillNumberStoreParameter
    with _$SettingTodayPillNumberStoreParameter {
  const factory SettingTodayPillNumberStoreParameter({
    required PillSheetGroup pillSheetGroup,
    required PillSheetAppearanceMode appearanceMode,
    required PillSheet activedPillSheet,
  }) = _SettingTodayPillNumberStoreParameter;
}
