import 'package:flutter/material.dart';
import 'package:pilll/components/atoms/font.dart';
import 'package:pilll/components/atoms/text_color.dart';
import 'package:pilll/domain/calendar/components/pill_sheet_modified_history/components/core/day.dart';
import 'package:pilll/domain/calendar/components/pill_sheet_modified_history/components/core/effective_pill_number.dart';
import 'package:pilll/domain/calendar/components/pill_sheet_modified_history/components/core/row_layout.dart';
import 'package:pilll/entity/pill_sheet_modified_history_value.codegen.dart';

class PillSheetModifiedHistoryDeletedPillSheetAction extends StatelessWidget {
  final DateTime estimatedEventCausingDate;
  final DeletedPillSheetValue? value;

  const PillSheetModifiedHistoryDeletedPillSheetAction({
    Key? key,
    required this.estimatedEventCausingDate,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RowLayout(
      day: Day(estimatedEventCausingDate: estimatedEventCausingDate),
      effectiveNumbersOrHyphen: EffectivePillNumber(
          effectivePillNumber:
              PillSheetModifiedHistoryDateEffectivePillNumber.pillSheetCount(
                  value?.pillSheetIDs ?? [])),
      detail: const Text(
        "ピルシート破棄",
        style: TextStyle(
          color: TextColor.main,
          fontSize: 12,
          fontFamily: FontFamily.japanese,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
