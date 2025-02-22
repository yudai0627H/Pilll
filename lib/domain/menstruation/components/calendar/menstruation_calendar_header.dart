import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pilll/analytics.dart';
import 'package:pilll/components/molecules/shadow_container.dart';
import 'package:pilll/components/organisms/calendar/band/calendar_band_model.dart';
import 'package:pilll/domain/menstruation/components/calendar/menstruation_single_line_state.dart';
import 'package:pilll/components/organisms/calendar/week/week_calendar.dart';
import 'package:pilll/domain/calendar/date_range.dart';
import 'package:pilll/components/organisms/calendar/band/calendar_band_function.dart';
import 'package:pilll/domain/menstruation/menstruation_page.dart';
import 'package:pilll/domain/menstruation/menstruation_state.codegen.dart';
import 'package:pilll/domain/record/weekday_badge.dart';
import 'package:pilll/entity/weekday.dart';

const double _horizontalPadding = 10;

class MenstruationCalendarHeader extends StatelessWidget {
  const MenstruationCalendarHeader({
    Key? key,
    required this.state,
    required this.pageController,
  }) : super(key: key);

  final MenstruationState state;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return ShadowContainer(
      child: Container(
        padding: const EdgeInsets.only(
          left: _horizontalPadding,
          right: _horizontalPadding,
        ),
        width: MediaQuery.of(context).size.width,
        height: MenstruationPageConst.calendarHeaderHeight,
        child: Column(
          children: [
            _WeekdayLine(),
            LimitedBox(
              maxHeight: MenstruationPageConst.tileHeight,
              child: PageView.builder(
                controller: pageController,
                physics: const PageScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final days = menstruationWeekCalendarDataSource[index];
                  return SizedBox(
                    width: MediaQuery.of(context).size.width - _horizontalPadding * 2,
                    height: MenstruationPageConst.tileHeight,
                    child: CalendarWeekdayLine(
                      state: MenstruationSinglelineWeekCalendarState(
                        dateRange: DateRange(days.first, days.last),
                        diariesForMonth: state.diariesForAround90Days,
                        allBandModels: buildBandModels(state.latestPillSheetGroup, state.setting, state.menstruations, 12)
                            .where((element) => element is! CalendarNextPillSheetBandModel)
                            .toList(),
                      ),
                      horizontalPadding: _horizontalPadding,
                      onTap: (weekCalendarState, date) {
                        analytics.logEvent(name: "did_select_day_tile_on_menstruation");
                        transitionToDiaryPost(context, date, state.diariesForAround90Days);
                      },
                      calendarMenstruationBandModels: state.calendarMenstruationBandModels,
                      calendarNextPillSheetBandModels: state.calendarNextPillSheetBandModels,
                      calendarScheduledMenstruationBandModels: state.calendarScheduledMenstruationBandModels,
                    ),
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

class _WeekdayLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(Weekday.values.length, (index) => Expanded(child: WeekdayBadge(weekday: Weekday.values[index]))),
    );
  }
}
