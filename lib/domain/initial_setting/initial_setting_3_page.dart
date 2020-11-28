import 'package:Pilll/router/router.dart';
import 'package:Pilll/components/organisms/setting/setting_menstruation_page.dart';
import 'package:Pilll/domain/initial_setting/initial_setting_4_page.dart';
import 'package:Pilll/store/initial_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';

class InitialSetting3Page extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final store = useProvider(initialSettingStoreProvider);
    final state = useProvider(initialSettingStoreProvider.state);
    return SettingMenstruationPage(
      title: "3/4",
      doneText: "次へ",
      done: () {
        Navigator.of(context).push(InitialSetting4PageRoute.route());
      },
      skip: () {
        store
            .register(state.entity)
            .then((_) => AppRouter.endInitialSetting(context));
      },
      model: SettingMenstruationPageModel(
        selectedFromMenstruation: state.entity.fromMenstruation,
        selectedDurationMenstruation: state.entity.durationMenstruation,
      ),
      fromMenstructionDidDecide: (selectedFromMenstruction) {
        store.modify((model) =>
            model.copyWith(fromMenstruation: selectedFromMenstruction));
      },
      durationMenstructionDidDecide: (selectedDurationMenstruation) {
        store.modify((model) =>
            model.copyWith(durationMenstruation: selectedDurationMenstruation));
      },
    );
  }
}

extension InitialSetting3PageRoute on InitialSetting3Page {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: "InitialSetting3Page"),
      builder: (_) => InitialSetting3Page(),
    );
  }
}
