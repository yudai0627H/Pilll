import 'dart:async';

import 'package:pilll/domain/record/record_page_store.dart';
import 'package:pilll/entity/setting.dart';
import 'package:pilll/service/pill_sheet.dart';
import 'package:pilll/service/setting.dart';
import 'package:pilll/domain/settings/setting_page_state.dart';
import 'package:pilll/service/user.dart';
import 'package:pilll/util/shared_preference/keys.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingStoreProvider = StateNotifierProvider(
  (ref) => SettingStateStore(
    ref.watch(settingServiceProvider),
    ref.watch(pillSheetServiceProvider),
    ref.watch(userServiceProvider),
  ),
);

class SettingStateStore extends StateNotifier<SettingState> {
  final SettingService _service;
  final PillSheetService _pillSheetService;
  final UserService _userService;
  SettingStateStore(
    this._service,
    this._pillSheetService,
    this._userService,
  ) : super(SettingState(entity: null)) {
    _reset();
  }

  void _reset() {
    Future(() async {
      final storage = await SharedPreferences.getInstance();
      final userIsMigratedFrom132 =
          storage.containsKey(StringKey.salvagedOldStartTakenDate) &&
              storage.containsKey(StringKey.salvagedOldLastTakenDate);
      final entity = await _service.fetch();
      final pillSheet = await _pillSheetService.fetchLast();
      final user = await _userService.fetch();
      this.state = SettingState(
        entity: entity,
        userIsUpdatedFrom132: userIsMigratedFrom132,
        latestPillSheet: pillSheet,
        isPremium: user.isPremium,
        isTrial: user.isTrial,
        trialDeadlineDate: user.trialDeadlineDate,
      );
      _subscribe();
    });
  }

  StreamSubscription? _canceller;
  StreamSubscription? _pillSheetCanceller;
  StreamSubscription? _userSubscribeCanceller;
  void _subscribe() {
    _canceller?.cancel();
    _canceller = _service.subscribe().listen((event) {
      state = state.copyWith(entity: event);
    });
    _pillSheetCanceller?.cancel();
    _pillSheetCanceller =
        _pillSheetService.subscribeForLatestPillSheet().listen((event) {
      state = state.copyWith(latestPillSheet: event);
    });
    _userSubscribeCanceller?.cancel();
    _userSubscribeCanceller = _userService.subscribe().listen((event) {
      state = state.copyWith(
        isPremium: event.isPremium,
        isTrial: event.isTrial,
        trialDeadlineDate: event.trialDeadlineDate,
      );
    });
  }

  @override
  void dispose() {
    _canceller?.cancel();
    _pillSheetCanceller?.cancel();
    _userSubscribeCanceller?.cancel();
    super.dispose();
  }

  void _modifyReminderTimes(List<ReminderTime> reminderTimes) {
    final entity = state.entity;
    if (entity == null) {
      throw FormatException("setting entity not found");
    }
    if (reminderTimes.length > ReminderTime.maximumCount) {
      throw Exception("登録できる上限に達しました。${ReminderTime.maximumCount}件以内に収めてください");
    }
    if (reminderTimes.length < ReminderTime.minimumCount) {
      throw Exception("通知時刻は最低${ReminderTime.minimumCount}件必要です");
    }
    _service
        .update(entity.copyWith(reminderTimes: reminderTimes))
        .then((entity) => state = state.copyWith(entity: entity));
  }

  void addReminderTimes(ReminderTime reminderTime) {
    final entity = state.entity;
    if (entity == null) {
      throw FormatException("setting entity not found");
    }
    List<ReminderTime> copied = [...entity.reminderTimes];
    copied.add(reminderTime);
    _modifyReminderTimes(copied);
  }

  void editReminderTime(int index, ReminderTime reminderTime) {
    final entity = state.entity;
    if (entity == null) {
      throw FormatException("setting entity not found");
    }
    List<ReminderTime> copied = [...entity.reminderTimes];
    copied[index] = reminderTime;
    _modifyReminderTimes(copied);
  }

  void deleteReminderTimes(int index) {
    final entity = state.entity;
    if (entity == null) {
      throw FormatException("setting entity not found");
    }
    List<ReminderTime> copied = [...entity.reminderTimes];
    copied.removeAt(index);
    _modifyReminderTimes(copied);
  }

  Future<SettingState> modifyIsOnReminder(bool isOnReminder) {
    final entity = state.entity;
    if (entity == null) {
      throw FormatException("setting entity not found");
    }
    return _service
        .update(entity.copyWith(isOnReminder: isOnReminder))
        .then((entity) => state = state.copyWith(entity: entity));
  }

  Future<SettingState> modifyIsOnNotifyInNotTakenDuration(bool isOn) {
    final entity = state.entity;
    if (entity == null) {
      throw FormatException("setting entity not found");
    }
    return _service
        .update(entity.copyWith(isOnNotifyInNotTakenDuration: isOn))
        .then((entity) => state = state.copyWith(entity: entity));
  }

  Future<void> modifyFromMenstruation(int fromMenstruation) {
    final entity = state.entity;
    if (entity == null) {
      throw FormatException("setting entity not found");
    }
    return _service
        .update(
            entity.copyWith(pillNumberForFromMenstruation: fromMenstruation))
        .then((entity) => state = state.copyWith(entity: entity));
  }

  Future<void> modifyDurationMenstruation(int durationMenstruation) {
    final entity = state.entity;
    if (entity == null) {
      throw FormatException("setting entity not found");
    }
    return _service
        .update(entity.copyWith(durationMenstruation: durationMenstruation))
        .then((entity) => state = state.copyWith(entity: entity));
  }

  void update(Setting? entity) {
    state = state.copyWith(entity: entity);
  }

  void modifyBeginingDate(int pillNumber) {
    final entity = state.latestPillSheet;
    if (entity == null) {
      throw FormatException("pill sheet not found");
    }

    modifyBeginingDateFunction(_pillSheetService, entity, pillNumber)
        .then((entity) => state = state.copyWith(latestPillSheet: entity));
  }

  Future<void> deletePillSheet() {
    final entity = state.latestPillSheet;
    if (entity == null) {
      throw FormatException("pill sheet not found");
    }
    return _pillSheetService.delete(entity);
  }

  Future<void> modifyPillSheetAppearanceMode(PillSheetAppearanceMode mode) {
    final entity = state.entity;
    if (entity == null) {
      throw FormatException("setting entity not found");
    }
    final updated = entity.copyWith(pillSheetAppearanceMode: mode);
    return _service
        .update(updated)
        .then((value) => state = state.copyWith(entity: value));
  }

  Future<SettingState> modifiyIsAutomaticallyCreatePillSheet(bool isOn) {
    final entity = state.entity;
    if (entity == null) {
      throw FormatException("setting entity not found");
    }
    return _service
        .update(entity.copyWith(isAutomaticallyCreatePillSheet: isOn))
        .then((entity) => state = state.copyWith(entity: entity));
  }
}
