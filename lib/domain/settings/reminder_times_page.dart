import 'dart:async';

import 'package:pilll/analytics.dart';
import 'package:pilll/domain/settings/setting_page_state.codegen.dart';
import 'package:pilll/domain/settings/timezone_setting_dialog.dart';
import 'package:pilll/entity/setting.codegen.dart';
import 'package:pilll/domain/settings/setting_page_state_notifier.dart';
import 'package:pilll/components/atoms/color.dart';
import 'package:pilll/components/atoms/font.dart';
import 'package:pilll/components/atoms/text_color.dart';
import 'package:pilll/error/error_alert.dart';
import 'package:pilll/util/formatter/date_time_formatter.dart';
import 'package:pilll/util/toolbar/time_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class ReminderTimesPage extends HookConsumerWidget {
  final SettingStateNotifier store;

  const ReminderTimesPage({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingStateProvider).value!;
    final setting = state.setting;

    return Scaffold(
      backgroundColor: PilllColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "通知時間",
          style: TextStyle(color: TextColor.black),
        ),
        actions: [
          IconButton(
              onPressed: () {
                analytics.logEvent(name: "pressed_tz_setting_action");
                showDialog(
                    context: context,
                    builder: (_) => TimezoneSettingDialog(
                          state: state,
                          stateNotifier: store,
                          onDone: (tz) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 2),
                                content: Text("$tzに変更しました"),
                              ),
                            );
                          },
                        ));
              },
              icon:
                  const Icon(Icons.timer_sharp, color: PilllColors.secondary)),
        ],
        backgroundColor: PilllColors.background,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ...setting.reminderTimes
                .asMap()
                .map(
                  (offset, reminderTime) => MapEntry(
                    offset,
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Container(
                            height: 1,
                            color: PilllColors.border,
                          ),
                        ),
                        _component(
                            context, store, setting, reminderTime, offset + 1)
                      ],
                    ),
                  ),
                )
                .values,
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Container(
                height: 1,
                color: PilllColors.border,
              ),
            ),
            _add(context, state, store),
          ],
        ),
      ),
    );
  }

  Widget _component(
    BuildContext context,
    SettingStateNotifier store,
    Setting setting,
    ReminderTime reminderTime,
    int number,
  ) {
    Widget body = GestureDetector(
      onTap: () {
        analytics.logEvent(name: "show_modify_reminder_time");
        _showPicker(context, store, setting, number - 1);
      },
      child: ListTile(
        title: Text("通知$number"),
        subtitle: Text(DateTimeFormatter.militaryTime(reminderTime.dateTime())),
      ),
    );
    if (setting.reminderTimes.length == 1) {
      return body;
    }
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: setting.reminderTimes.length == 1
          ? null
          : (direction) {
              analytics.logEvent(name: "delete_reminder_time");
              store.asyncAction
                  .deleteReminderTimes(index: number - 1, setting: setting)
                  .catchError((error) => showErrorAlert(context, error));
            },
      background: Container(
        color: Colors.red,
        child: SizedBox(
          width: 40,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "削除",
                style: FontType.assistingBold.merge(TextColorStyle.white),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ),
      ),
      child: body,
    );
  }

  Widget _add(
      BuildContext context, SettingState state, SettingStateNotifier store) {
    final setting = state.setting;
    if (setting.reminderTimes.length >= ReminderTime.maximumCount) {
      return Container();
    }
    return GestureDetector(
      onTap: () {
        analytics.logEvent(name: "pressed_add_reminder_time");
        _showPicker(context, store, setting, null);
      },
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("images/add.svg"),
            Text(
              "通知時間の追加",
              style: FontType.assisting.merge(TextColorStyle.main),
            )
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, SettingStateNotifier store,
      Setting setting, int? index) {
    final isEditing = index != null;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return TimePicker(
          initialDateTime: isEditing
              ? setting.reminderTimes[index].dateTime()
              : const ReminderTime(hour: 20, minute: 0).dateTime(),
          done: (dateTime) {
            if (isEditing) {
              analytics.logEvent(name: "edited_reminder_time");
              unawaited(store.asyncAction
                  .editReminderTime(
                    index: index,
                    reminderTime: ReminderTime(
                        hour: dateTime.hour, minute: dateTime.minute),
                    setting: setting,
                  )
                  .catchError((error) => showErrorAlert(context, error)));
            } else {
              analytics.logEvent(name: "added_reminder_time");
              unawaited(store.asyncAction
                  .addReminderTimes(
                      reminderTime: ReminderTime(
                          hour: dateTime.hour, minute: dateTime.minute),
                      setting: setting)
                  .catchError((error) => showErrorAlert(context, error)));
            }

            Navigator.pop(context);
          },
        );
      },
    );
  }
}

extension ReminderTimesPageRoute on ReminderTimesPage {
  static Route<dynamic> route({
    required SettingStateNotifier store,
  }) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: "ReminderTimesPage"),
      builder: (_) => ReminderTimesPage(store: store),
    );
  }
}
