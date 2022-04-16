import 'dart:async';

import 'package:pilll/database/batch.dart';
import 'package:pilll/domain/settings/today_pill_number/setting_today_pill_number_state.codegen.dart';
import 'package:pilll/domain/settings/today_pill_number/setting_today_pill_number_store_parameter.codegen.dart';
import 'package:pilll/entity/local_notification_schedule.codegen.dart';
import 'package:pilll/entity/pill_sheet.codegen.dart';
import 'package:pilll/entity/pill_sheet_group.codegen.dart';
import 'package:pilll/entity/pill_sheet_type.dart';
import 'package:pilll/service/local_notification.dart';
import 'package:pilll/service/local_notification_schedule.dart';
import 'package:pilll/service/pill_sheet.dart';
import 'package:pilll/service/pill_sheet_group.dart';
import 'package:pilll/service/pill_sheet_modified_history.dart';
import 'package:pilll/util/datetime/day.dart';
import 'package:riverpod/riverpod.dart';

final settingTodayPillNumberStoreProvider = StateNotifierProvider.autoDispose
    .family<SettingTodayPillNumberStateStore, SettingTodayPillNumberState,
        SettingTodayPillNumberStoreParameter>(
  (ref, parameter) => SettingTodayPillNumberStateStore(
    parameter,
    ref.watch(batchFactoryProvider),
    ref.watch(pillSheetServiceProvider),
    ref.watch(pillSheetGroupServiceProvider),
    ref.watch(pillSheetModifiedHistoryServiceProvider),
    ref.watch(localNotificationScheduleCollectionServiceProvider),
  ),
);

class SettingTodayPillNumberStateStore
    extends StateNotifier<SettingTodayPillNumberState> {
  final BatchFactory _batchFactory;
  final PillSheetService _pillSheetService;
  final PillSheetGroupService _pillSheetGroupService;
  final PillSheetModifiedHistoryService _pillSheetModifiedHistoryService;
  final LocalNotificationScheduleCollectionService
      _localNotificationScheduleCollectionService;

  SettingTodayPillNumberStateStore(
    SettingTodayPillNumberStoreParameter _parameter,
    this._batchFactory,
    this._pillSheetService,
    this._pillSheetGroupService,
    this._pillSheetModifiedHistoryService,
    this._localNotificationScheduleCollectionService,
  ) : super(
          SettingTodayPillNumberState(
            setting: _parameter.setting,
            appearanceMode: _parameter.appearanceMode,
            selectedPillSheetPageIndex: _parameter.activedPillSheet.groupIndex,
            selectedPillMarkNumberIntoPillSheet: _pillNumberIntoPillSheet(
              activedPillSheet: _parameter.activedPillSheet,
              pillSheetGroup: _parameter.pillSheetGroup,
            ),
            isTrial: _parameter.isTrial,
            isPremium: _parameter.isPremium,
          ),
        );

  markSelected({
    required int pageIndex,
    required int pillNumberIntoPillSheet,
  }) {
    state = state.copyWith(
      selectedPillMarkNumberIntoPillSheet: pillNumberIntoPillSheet,
      selectedPillSheetPageIndex: pageIndex,
    );
  }

  Future<void> modifiyTodayPillNumber({
    required PillSheetGroup pillSheetGroup,
    required PillSheet activedPillSheet,
  }) async {
    final batch = _batchFactory.batch();

    final pillSheetTypes =
        pillSheetGroup.pillSheets.map((e) => e.pillSheetType).toList();
    final nextSerializedPillNumber =
        summarizedPillCountWithPillSheetTypesToEndIndex(
              pillSheetTypes: pillSheetTypes,
              endIndex: state.selectedPillSheetPageIndex,
            ) +
            state.selectedPillMarkNumberIntoPillSheet;
    final firstPilSheetBeginDate =
        today().subtract(Duration(days: nextSerializedPillNumber - 1));

    final List<PillSheet> updatedPillSheets = [];
    pillSheetGroup.pillSheets.asMap().keys.forEach((index) {
      final pillSheet = pillSheetGroup.pillSheets[index];

      final DateTime beginDate;
      if (index == 0) {
        beginDate = firstPilSheetBeginDate;
      } else {
        final passedTotalCount =
            summarizedPillCountWithPillSheetTypesToEndIndex(
                pillSheetTypes: pillSheetTypes, endIndex: index);
        beginDate =
            firstPilSheetBeginDate.add(Duration(days: passedTotalCount));
      }

      final DateTime? lastTakenDate;
      if (state.selectedPillSheetPageIndex == index) {
        lastTakenDate = beginDate
            .add(Duration(days: state.selectedPillMarkNumberIntoPillSheet - 2));
      } else if (state.selectedPillSheetPageIndex > index) {
        lastTakenDate = beginDate
            .add(Duration(days: pillSheet.pillSheetType.totalCount - 1));
      } else {
        // state.selectedPillMarkNumberIntoPillSheet < index
        lastTakenDate = null;
      }

      final updatedPillSheet = pillSheet.copyWith(
          beginingDate: beginDate,
          lastTakenDate: lastTakenDate,
          restDurations: []);
      updatedPillSheets.add(updatedPillSheet);
    });

    _pillSheetService.update(batch, updatedPillSheets);

    final history = PillSheetModifiedHistoryServiceActionFactory
        .createChangedPillNumberAction(
      pillSheetGroupID: pillSheetGroup.id,
      before: activedPillSheet,
      after: updatedPillSheets[state.selectedPillSheetPageIndex],
    );
    _pillSheetModifiedHistoryService.add(batch, history);

    _pillSheetGroupService.update(
        batch, pillSheetGroup.copyWith(pillSheets: updatedPillSheets));

    await batch.commit();

    final currentLocalNotificationScheduleCollection =
        await _localNotificationScheduleCollectionService
            .fetchReminderNotification();
    if (currentLocalNotificationScheduleCollection != null) {
      localNotification.cancelAllScheduledRemiderNotification(
          localNotificationScheduleCollection:
              currentLocalNotificationScheduleCollection);
    }

    final localNotificationScheduleCollection =
        LocalNotificationScheduleCollection.reminderNotification(
      reminderNotificationLocalNotificationScheduleCollection:
          currentLocalNotificationScheduleCollection?.schedules ?? [],
      pillSheetGroup: pillSheetGroup,
      activedPillSheet: activedPillSheet,
      isTrialOrPremium: state.isTrial || state.isPremium,
      setting: state.setting!,
      tzFrom: now().tzDate(),
    );
    await localNotification.scheduleRemiderNotification(
      localNotificationScheduleCollection: localNotificationScheduleCollection,
      isTrialOrPremium: state.isTrial || state.isPremium,
    );
  }
}

int _pillNumberIntoPillSheet({
  required PillSheet activedPillSheet,
  required PillSheetGroup pillSheetGroup,
}) {
  final pillSheetTypes =
      pillSheetGroup.pillSheets.map((e) => e.pillSheetType).toList();
  final _passedTotalCount = summarizedPillCountWithPillSheetTypesToEndIndex(
      pillSheetTypes: pillSheetTypes, endIndex: activedPillSheet.groupIndex);
  if (_passedTotalCount >= activedPillSheet.todayPillNumber) {
    return activedPillSheet.todayPillNumber;
  }
  return activedPillSheet.todayPillNumber - _passedTotalCount;
}
