import 'package:flutter/material.dart';
import 'package:pilll/analytics.dart';
import 'package:pilll/components/atoms/color.dart';
import 'package:pilll/components/atoms/font.dart';
import 'package:pilll/components/atoms/text_color.dart';
import 'package:pilll/components/template/pill_sheet_type_setting/pill_sheet_type_select_body_template.dart';
import 'package:pilll/entity/pill_sheet_type.dart';

class PillSheetGroupSelectPillSheetTypePage extends StatelessWidget {
  final PillSheetType? pillSheetType;
  final Function(PillSheetType) onSelect;

  const PillSheetGroupSelectPillSheetTypePage(
      {Key? key, required this.pillSheetType, required this.onSelect})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: PilllColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    SizedBox(width: 16),
                    Text(
                      "ピルの種類を選択",
                      style: TextStyle(
                        color: TextColor.main,
                        fontSize: 20,
                        fontFamily: FontFamily.japanese,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      PillSheetTypeSelectBodyTemplate(
                        onSelect: (e) {
                          analytics.logEvent(
                            name: "initial_setting_selected_pill_sheet_type",
                            parameters: {"pill_sheet_type": e.fullName},
                          );
                          Navigator.of(context).pop();
                          onSelect(e);
                        },
                        selectedFirstPillSheetType: pillSheetType,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void showSettingPillSheetGroupSelectPillSheetTypePage({
  required BuildContext context,
  required final PillSheetType? pillSheetType,
  required final Function(PillSheetType) onSelect,
}) {
  analytics.setCurrentScreen(
      screenName: "PillSheetGroupSelectPillSheetTypePage");
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PillSheetGroupSelectPillSheetTypePage(
      pillSheetType: pillSheetType,
      onSelect: onSelect,
    ),
  );
}
