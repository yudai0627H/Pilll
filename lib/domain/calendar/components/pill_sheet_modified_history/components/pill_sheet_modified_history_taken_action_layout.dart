import 'package:flutter/material.dart';
import 'package:pilll/components/atoms/color.dart';
import 'package:pilll/components/atoms/font.dart';
import 'package:pilll/components/atoms/text_color.dart';
import 'package:pilll/entity/weekday.dart';

abstract class PillSheetModifiedHistoryTakenActionLayoutWidths {
  static final double leading = 160;
  static final double takenTime = 53;
  static final double takenMark = 53;
  static final double actionDescription = 100;
}

class PillSheetModifiedHistoryDate extends StatelessWidget {
  final DateTime createdAt;
  final int? pillNumber;

  const PillSheetModifiedHistoryDate({
    Key? key,
    required this.createdAt,
    required this.pillNumber,
  }) : super(key: key);

  int get _day => createdAt.day;
  Weekday get _weekday => WeekdayFunctions.weekdayFromDate(createdAt);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: PillSheetModifiedHistoryTakenActionLayoutWidths.leading,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            "$_day",
            style: TextStyle(
              color: TextColor.main,
              fontFamily: FontFamily.number,
              fontSize: 23,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          Text(
            "(${_weekday.weekdayString()})",
            style: TextStyle(
              color: TextColor.main,
              fontFamily: FontFamily.japanese,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 12),
          Container(
            height: 26,
            child: VerticalDivider(
              color: PilllColors.divider,
              width: 0.5,
            ),
          ),
          SizedBox(width: 16),
          if (pillNumber != null)
            Text(
              "$pillNumber番",
              style: TextStyle(
                color: TextColor.main,
                fontFamily: FontFamily.japanese,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          if (pillNumber == null)
            Text(
              "-",
              style: TextStyle(
                color: TextColor.main,
                fontFamily: FontFamily.japanese,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
