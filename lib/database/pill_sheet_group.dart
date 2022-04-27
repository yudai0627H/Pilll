import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pilll/database/database.dart';
import 'package:pilll/entity/pill_sheet_group.codegen.dart';
import 'package:riverpod/riverpod.dart';

final pillSheetGroupDatastoreProvider = Provider<PillSheetGroupDatastore>(
    (ref) => PillSheetGroupDatastore(ref.watch(databaseProvider)));

class PillSheetGroupDatastore {
  final DatabaseConnection _database;

  PillSheetGroupDatastore(this._database);

  Query<PillSheetGroup> _latestQuery() {
    return _database
        .pillSheetGroupsReference()
        .orderBy(PillSheetGroupFirestoreKeys.createdAt)
        .limitToLast(1);
  }

  PillSheetGroup? _filter(QuerySnapshot<PillSheetGroup> snapshot) {
    if (snapshot.docs.isEmpty) return null;
    if (!snapshot.docs.last.exists) return null;
    return snapshot.docs.last.data();
  }

  Future<PillSheetGroup?> fetchLatest() async {
    final snapshot = await _latestQuery().get();
    return _filter(snapshot);
  }

  Future<PillSheetGroup?> fetchBeforePillSheetGroup() async {
    final snapshot = await _database
        .pillSheetGroupsReference()
        .orderBy(PillSheetGroupFirestoreKeys.createdAt)
        .limitToLast(2)
        .get();
    if (snapshot.docs.length <= 1) {
      return null;
    }

    return snapshot.docs[0].data();
  }

  late Stream<PillSheetGroup> _latestPillSheetGroupStream = _latestQuery()
      .snapshots()
      .map(((event) => _filter(event)))
      .where((event) => event != null)
      .cast();
  Stream<PillSheetGroup> latestPillSheetGroupStream() =>
      _latestPillSheetGroupStream;

  // Return new PillSheet document id
  PillSheetGroup register(WriteBatch batch, PillSheetGroup pillSheetGroup) {
    if (pillSheetGroup.deletedAt != null) throw PillSheetGroupAlreadyDeleted();

    final copied = pillSheetGroup.copyWith(createdAt: DateTime.now());
    final newDocument = _database.pillSheetGroupsReference().doc();
    batch.set(newDocument, copied.toJson(), SetOptions(merge: true));
    return copied.copyWith(id: newDocument.id);
  }

  PillSheetGroup delete(WriteBatch batch, PillSheetGroup pillSheetGroup) {
    if (pillSheetGroup.deletedAt != null) throw PillSheetGroupAlreadyDeleted();

    final updated = pillSheetGroup.copyWith(deletedAt: DateTime.now());
    batch.set(_database.pillSheetGroupReference(pillSheetGroup.id!),
        updated.toJson(), SetOptions(merge: true));
    return updated;
  }

  Future<void> update(PillSheetGroup pillSheetGroup) async {
    await _database
        .pillSheetGroupReference(pillSheetGroup.id!)
        .update(pillSheetGroup.toJson());
  }

  void updateWithBatch(WriteBatch batch, PillSheetGroup pillSheetGroup) {
    final json = pillSheetGroup.toJson();
    batch.update(_database.pillSheetGroupReference(pillSheetGroup.id!), json);
  }
}

class PillSheetGroupAlreadyExists extends Error {
  @override
  toString() {
    return "ピルシートグループがすでに存在しています。";
  }
}

class PillSheetGroupAlreadyDeleted extends Error {
  @override
  String toString() {
    return "ピルシートグループはすでに削除されています。";
  }
}
