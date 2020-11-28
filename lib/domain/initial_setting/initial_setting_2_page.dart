import 'package:Pilll/router/router.dart';
import 'package:Pilll/store/initial_setting.dart';
import 'package:Pilll/components/atoms/buttons.dart';
import 'package:Pilll/components/atoms/color.dart';
import 'package:Pilll/domain/initial_setting/initial_setting_3_page.dart';
import 'package:Pilll/components/organisms/pill/pill_sheet.dart';
import 'package:Pilll/components/atoms/font.dart';
import 'package:Pilll/components/atoms/text_color.dart';
import 'package:Pilll/util/datetime/day.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';

class InitialSetting2Page extends HookWidget {
  const InitialSetting2Page({Key key}) : super(key: key);

  String todayString() {
    return DateFormat.yMd('ja').format(today());
  }

  @override
  Widget build(BuildContext context) {
    final store = useProvider(initialSettingStoreProvider);
    final state = useProvider(initialSettingStoreProvider.state);
    return Scaffold(
      backgroundColor: PilllColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "2/4",
          style: TextStyle(color: TextColor.black),
        ),
        backgroundColor: PilllColors.background,
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 24),
              Text(
                "今日(${todayString()})\n飲む・飲んだピルの番号をタップ",
                style: FontType.title.merge(TextColorStyle.standard),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              PillSheet(
                pillMarkTypeBuilder: (number) {
                  return state.entity.pillMarkTypeFor(number);
                },
                enabledMarkAnimation: null,
                markSelected: (number) {
                  store.modify(
                      (model) => model.copyWith(todayPillNumber: number));
                },
              ),
              SizedBox(height: 24),
              ExplainPillNumber(today: todayString()),
              SizedBox(height: 24),
              Wrap(
                direction: Axis.vertical,
                spacing: 8,
                children: <Widget>[
                  PrimaryButton(
                    text: "次へ",
                    onPressed: state.entity.todayPillNumber == null
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return InitialSetting3Page();
                                },
                              ),
                            );
                          },
                  ),
                  TertiaryButton(
                    text: "スキップ",
                    onPressed: () {
                      store
                          .register(state.entity)
                          .then((_) => AppRouter.endInitialSetting(context));
                    },
                  ),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class ExplainPillNumber extends HookWidget {
  final String today;

  const ExplainPillNumber({Key key, this.today}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final state = useProvider(initialSettingStoreProvider.state);
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.ideographic,
        children: () {
          if (state.entity.todayPillNumber == null) {
            return <Widget>[
              Text("", style: FontType.largeNumber.merge(TextColorStyle.black)),
            ];
          }
          return <Widget>[
            Text("$todayに飲むピルは",
                style: FontType.description.merge(TextColorStyle.black)),
            Text("${state.entity.todayPillNumber}",
                style: FontType.largeNumber.merge(TextColorStyle.black)),
            Text("番", style: FontType.description.merge(TextColorStyle.black)),
          ];
        }(),
      ),
    );
  }
}

extension InitialSetting2PageRoute on InitialSetting2Page {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: "InitialSetting2PageRoute"),
      builder: (_) => InitialSetting2Page(),
    );
  }
}
