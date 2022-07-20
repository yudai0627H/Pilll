import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pilll/database/pill_sheet_modified_history.dart';
import 'package:pilll/domain/record/util/take_pill.dart';
import 'package:pilll/entity/pill_sheet.codegen.dart';
import 'package:pilll/entity/pill_sheet_group.codegen.dart';
import 'package:pilll/entity/pill_sheet_modified_history.codegen.dart';
import 'package:pilll/entity/pill_sheet_type.dart';
import 'package:pilll/service/day.dart';
import 'package:pilll/util/datetime/day.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/mock.mocks.dart';

void main() {
  final _today = DateTime.parse("2022-07-20");
  late DateTime activePillSheetBeginDate;
  late DateTime? activePillSheetLastTakenDate;
  late PillSheet previousPillSheet;
  late PillSheet activedPillSheet;
  late PillSheet nextPillSheet;
  late PillSheetGroup pillSheetGroup;

  group("#TakePill", () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();

      final mockTodayRepository = MockTodayService();
      todayRepository = mockTodayRepository;
      when(mockTodayRepository.now()).thenReturn(_today);

      activePillSheetBeginDate = _today;
      activePillSheetLastTakenDate = null;
      previousPillSheet = PillSheet(
        id: "previous_pill_sheet_id",
        typeInfo: PillSheetType.pillsheet_28_7.typeInfo,
        beginingDate: activePillSheetBeginDate.subtract(const Duration(days: 28)),
        lastTakenDate: activePillSheetBeginDate.subtract(const Duration(days: 1)),
      );
      activedPillSheet = PillSheet(
        id: "active_pill_sheet_id",
        typeInfo: PillSheetType.pillsheet_28_7.typeInfo,
        beginingDate: activePillSheetBeginDate,
        lastTakenDate: activePillSheetLastTakenDate,
      );
      nextPillSheet = PillSheet(
        id: "next_pill_sheet_group",
        typeInfo: PillSheetType.pillsheet_28_7.typeInfo,
        beginingDate: activePillSheetBeginDate.add(const Duration(days: 28)),
        lastTakenDate: null,
      );
    });
    group("one pill sheet", () {
      setUp(() {
        pillSheetGroup = PillSheetGroup(
          id: "group_id",
          pillSheetIDs: [activedPillSheet.id!],
          pillSheets: [activedPillSheet],
          createdAt: _today,
        );
      });

      test("take pill", () async {
        final takenDate = _today.add(const Duration(seconds: 1));

        final batchFactory = MockBatchFactory();
        final batch = MockWriteBatch();
        when(batchFactory.batch()).thenReturn(batch);

        final pillSheetDatastore = MockPillSheetDatastore();
        final updatedPillSheet = activedPillSheet.copyWith(lastTakenDate: takenDate);
        when(pillSheetDatastore.update(batch, [updatedPillSheet])).thenReturn(null);

        final pillSheetModifiedHistoryDatastore = MockPillSheetModifiedHistoryDatastore();
        final history = PillSheetModifiedHistoryServiceActionFactory.createTakenPillAction(
            pillSheetGroupID: pillSheetGroup.id, isQuickRecord: false, before: activedPillSheet, after: updatedPillSheet);
        when(pillSheetModifiedHistoryDatastore.add(batch, history)).thenReturn(null);

        final pillSheetGroupDatastore = MockPillSheetGroupDatastore();
        final updatedPillSheetGroup = pillSheetGroup.copyWith(pillSheets: [updatedPillSheet]);
        when(pillSheetGroupDatastore.updateWithBatch(batch, updatedPillSheetGroup)).thenReturn(null);

        final takePill = TakePill(
          batchFactory: batchFactory,
          pillSheetDatastore: pillSheetDatastore,
          pillSheetModifiedHistoryDatastore: pillSheetModifiedHistoryDatastore,
          pillSheetGroupDatastore: pillSheetGroupDatastore,
        );
        final result = await takePill(
          takenDate: takenDate,
          activedPillSheet: activedPillSheet,
          pillSheetGroup: pillSheetGroup,
          isQuickRecord: false,
        );

        expect(result, updatedPillSheetGroup);
      });

      test("activedPillSheet.todayPillIsAlreadyTaken", () async {
        final takenDate = _today.add(const Duration(seconds: 1));
        activedPillSheet = activedPillSheet.copyWith(lastTakenDate: takenDate);

        final batchFactory = MockBatchFactory();
        final pillSheetDatastore = MockPillSheetDatastore();
        final pillSheetModifiedHistoryDatastore = MockPillSheetModifiedHistoryDatastore();
        final pillSheetGroupDatastore = MockPillSheetGroupDatastore();

        final takePill = TakePill(
          batchFactory: batchFactory,
          pillSheetDatastore: pillSheetDatastore,
          pillSheetModifiedHistoryDatastore: pillSheetModifiedHistoryDatastore,
          pillSheetGroupDatastore: pillSheetGroupDatastore,
        );
        final result = await takePill(
          takenDate: takenDate,
          activedPillSheet: activedPillSheet,
          pillSheetGroup: pillSheetGroup,
          isQuickRecord: false,
        );

        expect(result, null);
      });
    });

    group("three pill sheet", () {
      test("take pill", () async {
        final takenDate = _today.add(const Duration(seconds: 1));

        final batchFactory = MockBatchFactory();
        final batch = MockWriteBatch();
        when(batchFactory.batch()).thenReturn(batch);

        final pillSheetDatastore = MockPillSheetDatastore();
        final updatedPillSheet = activedPillSheet.copyWith(lastTakenDate: takenDate);
        when(pillSheetDatastore.update(batch, [updatedPillSheet])).thenReturn(null);

        final pillSheetModifiedHistoryDatastore = MockPillSheetModifiedHistoryDatastore();
        final history = PillSheetModifiedHistoryServiceActionFactory.createTakenPillAction(
            pillSheetGroupID: pillSheetGroup.id, isQuickRecord: false, before: activedPillSheet, after: updatedPillSheet);
        when(pillSheetModifiedHistoryDatastore.add(batch, history)).thenReturn(null);

        final pillSheetGroupDatastore = MockPillSheetGroupDatastore();
        final updatedPillSheetGroup = pillSheetGroup.copyWith(pillSheets: [updatedPillSheet]);
        when(pillSheetGroupDatastore.updateWithBatch(batch, updatedPillSheetGroup)).thenReturn(null);

        final takePill = TakePill(
          batchFactory: batchFactory,
          pillSheetDatastore: pillSheetDatastore,
          pillSheetModifiedHistoryDatastore: pillSheetModifiedHistoryDatastore,
          pillSheetGroupDatastore: pillSheetGroupDatastore,
        );
        final result = await takePill(
          takenDate: takenDate,
          activedPillSheet: activedPillSheet,
          pillSheetGroup: pillSheetGroup,
          isQuickRecord: false,
        );

        expect(result, updatedPillSheetGroup);
      });

      test("activedPillSheet.todayPillIsAlreadyTaken", () async {
        final takenDate = _today.add(const Duration(seconds: 1));
        activedPillSheet = activedPillSheet.copyWith(lastTakenDate: takenDate);

        final batchFactory = MockBatchFactory();
        final pillSheetDatastore = MockPillSheetDatastore();
        final pillSheetModifiedHistoryDatastore = MockPillSheetModifiedHistoryDatastore();
        final pillSheetGroupDatastore = MockPillSheetGroupDatastore();

        final takePill = TakePill(
          batchFactory: batchFactory,
          pillSheetDatastore: pillSheetDatastore,
          pillSheetModifiedHistoryDatastore: pillSheetModifiedHistoryDatastore,
          pillSheetGroupDatastore: pillSheetGroupDatastore,
        );
        final result = await takePill(
          takenDate: takenDate,
          activedPillSheet: activedPillSheet,
          pillSheetGroup: pillSheetGroup,
          isQuickRecord: false,
        );

        expect(result, null);
      });
    });
  });
}
