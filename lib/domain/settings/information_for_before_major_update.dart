import 'package:pilll/components/atoms/color.dart';
import 'package:pilll/components/atoms/font.dart';
import 'package:pilll/components/atoms/text_color.dart';
import 'package:pilll/util/datetime/day.dart';
import 'package:flutter/material.dart';

class InformationForBeforeMigrate132 extends StatelessWidget {
  final String salvagedOldStartTakenDate;
  final String salvagedOldLastTakenDate;

  const InformationForBeforeMigrate132(
      {Key? key,
      required this.salvagedOldStartTakenDate,
      required this.salvagedOldLastTakenDate})
      : super(key: key);

  int _latestPillNumber() {
    final last = DateTime.parse(salvagedOldLastTakenDate);
    final start = DateTime.parse(salvagedOldStartTakenDate);
    return daysBetween(start, last) % 28 + 1;
  }

  int _todayPillNumber() {
    final start = DateTime.parse(salvagedOldStartTakenDate);
    return daysBetween(start, today()) % 28 + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: PilllColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: PilllColors.background,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "大型アップデート前の情報",
                  style: FontType.sBigTitle.merge(TextColorStyle.main),
                ),
                const SizedBox(height: 32),
                Text(
                  "下記の情報はversion 2.0.0以前のアプリの情報になります",
                  style: FontType.subTitle.merge(TextColorStyle.main),
                ),
                const SizedBox(height: 8),
                Text(
                  "最後に飲んだ日: $salvagedOldLastTakenDate",
                  style: FontType.listRow.merge(TextColorStyle.main),
                ),
                const SizedBox(height: 4),
                Text(
                  "※大型アップデート前のアプリで最後にピルの服用記録をつけた日です",
                  style: FontType.description.merge(TextColorStyle.gray),
                ),
                const SizedBox(height: 4),
                Text(
                  "最後に飲んだピル番号: ${_latestPillNumber()}",
                  style: FontType.listRow.merge(TextColorStyle.main),
                ),
                const SizedBox(height: 4),
                Text(
                  "※大型アップデート前のアプリで最後に服用したピル番号になります",
                  style: FontType.description.merge(TextColorStyle.gray),
                ),
                const SizedBox(height: 4),
                Text(
                  "今日服用予定だったピル番号: ${_todayPillNumber()}",
                  style: FontType.listRow.merge(TextColorStyle.main),
                ),
                const SizedBox(height: 4),
                Text(
                  "※大型アップデート前のアプリを使用していた場合の本日のピル番号になります",
                  style: FontType.description.merge(TextColorStyle.gray),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension InformationForBeforeMigrate132Route
    on InformationForBeforeMigrate132 {
  static Route<dynamic> route(
      {required String salvagedOldStartTakenDate,
      required String salvagedOldLastTakenDate}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: "InformationForBeforeMigrate132Route"),
      builder: (_) => InformationForBeforeMigrate132(
        salvagedOldStartTakenDate: salvagedOldStartTakenDate,
        salvagedOldLastTakenDate: salvagedOldLastTakenDate,
      ),
    );
  }
}
