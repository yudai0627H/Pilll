import 'dart:async';

import 'package:pilll/database/batch.dart';
import 'package:pilll/domain/record/components/add_pill_sheet_group/add_pill_sheet_group_state.codegen.dart';
import 'package:pilll/domain/record/record_page_state.codegen.dart';
import 'package:pilll/entity/pill_sheet.codegen.dart';
import 'package:pilll/entity/pill_sheet_group.codegen.dart';
import 'package:pilll/entity/pill_sheet_type.dart';
import 'package:pilll/entity/setting.codegen.dart';
import 'package:pilll/database/pill_sheet.dart';
import 'package:pilll/database/pill_sheet_group.dart';
import 'package:pilll/database/pill_sheet_modified_history.dart';
import 'package:pilll/database/setting.dart';
import 'package:pilll/util/datetime/day.dart';
import 'package:riverpod/riverpod.dart';

final addPillSheetGroupStateStoreProvider = StateNotifierProvider.autoDispose<
    AddPillSheetGroupStateStore, AddPillSheetGroupState>(
  (ref) {
    return AddPillSheetGroupStateStore(
      ref.watch(recordPageAsyncStateProvider).value!.pillSheetGroup,
      ref.watch(recordPageAsyncStateProvider).value!.appearanceMode,
      ref.watch(recordPageAsyncStateProvider).value!.setting,
      ref.watch(pillSheetDatastoreProvider),
      ref.watch(pillSheetGroupDatastoreProvider),
      ref.watch(settingDatastoreProvider),
      ref.watch(pillSheetModifiedHistoryDatastoreProvider),
      ref.watch(batchFactoryProvider),
    );
  },
);

class AddPillSheetGroupStateStore
    extends StateNotifier<AddPillSheetGroupState> {
  final PillSheetDatastore _pillSheetDatastore;
  final PillSheetGroupDatastore _pillSheetGroupDatastore;
  final SettingDatastore _settingDatastore;
  final PillSheetModifiedHistoryDatastore _pillSheetModifiedHistoryDatastore;
  final BatchFactory _batchFactory;
  AddPillSheetGroupStateStore(
    PillSheetGroup? pillSheetGroup,
    PillSheetAppearanceMode pillSheetAppearanceMode,
    Setting? setting,
    this._pillSheetDatastore,
    this._pillSheetGroupDatastore,
    this._settingDatastore,
    this._pillSheetModifiedHistoryDatastore,
    this._batchFactory,
  ) : super(AddPillSheetGroupState(
          pillSheetGroup: pillSheetGroup?.copyWith(),
          pillSheetAppearanceMode: pillSheetAppearanceMode,
          setting: setting?.copyWith(),
        ));

  void addPillSheetType(PillSheetType pillSheetType, Setting setting) {
    final updatedSetting = setting.copyWith(
        pillSheetTypes: setting.pillSheetTypes..add(pillSheetType));
    state = state.copyWith(setting: updatedSetting);
  }

  void changePillSheetType(
      int index, PillSheetType pillSheetType, Setting setting) {
    final copied = [...setting.pillSheetTypes];
    copied[index] = pillSheetType;

    final updatedSetting = setting.copyWith(pillSheetTypes: copied);
    state = state.copyWith(setting: updatedSetting);
  }

  void removePillSheetType(int index, Setting setting) {
    final copied = [...setting.pillSheetEnumTypes];
    copied.removeAt(index);

    final updatedSetting = setting.copyWith(pillSheetTypes: copied);
    state = state.copyWith(setting: updatedSetting);
  }

  void setBeginDisplayPillNumber(
    int beginDisplayPillNumber,
  ) {
    state = state.copyWith(
        displayNumberSetting: DisplayNumberSetting(
      beginPillNumber: beginDisplayPillNumber,
    ));
  }

  Future<void> register(Setting setting) async {
    final batch = _batchFactory.batch();

    final n = now();
    final createdPillSheets = _pillSheetDatastore.register(
      batch,
      setting.pillSheetTypes.asMap().keys.map((pageIndex) {
        final pillSheetType = setting.pillSheetEnumTypes[pageIndex];
        final offset = summarizedPillCountWithPillSheetTypesToEndIndex(
            pillSheetTypes: setting.pillSheetEnumTypes, endIndex: pageIndex);
        return PillSheet(
          typeInfo: pillSheetType.typeInfo,
          beginingDate: n.add(
            Duration(days: offset),
          ),
          groupIndex: pageIndex,
        );
      }).toList(),
    );

    final pillSheetIDs = createdPillSheets.map((e) => e.id!).toList();
    final createdPillSheetGroup = _pillSheetGroupDatastore.register(
      batch,
      PillSheetGroup(
        pillSheetIDs: pillSheetIDs,
        pillSheets: createdPillSheets,
        displayNumberSetting: () {
          if (state.pillSheetAppearanceMode ==
              PillSheetAppearanceMode.sequential) {
            if (state.displayNumberSetting != null) {
              return state.displayNumberSetting;
            }
            final pillSheetGroup = state.pillSheetGroup;
            if (pillSheetGroup != null) {
              return DisplayNumberSetting(
                beginPillNumber: pillSheetGroup.estimatedEndPillNumber + 1,
              );
            }

            return null;
          } else {
            return null;
          }
        }(),
        createdAt: now(),
      ),
    );

    final history = PillSheetModifiedHistoryServiceActionFactory
        .createCreatedPillSheetAction(
      pillSheetIDs: pillSheetIDs,
      pillSheetGroupID: createdPillSheetGroup.id,
    );
    _pillSheetModifiedHistoryDatastore.add(batch, history);

    _settingDatastore.updateWithBatch(batch, setting);

    return batch.commit();
  }
}
