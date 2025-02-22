import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pilll/database/database.dart';
import 'package:pilll/entity/setting.codegen.dart';
import 'package:pilll/entity/user.codegen.dart';
import 'package:riverpod/riverpod.dart';

final settingDatastoreProvider =
    Provider((ref) => SettingDatastore(ref.watch(databaseProvider)));

final settingStreamProvider =
    StreamProvider((ref) => ref.watch(settingDatastoreProvider).stream());

class SettingDatastore {
  final DatabaseConnection _database;
  SettingDatastore(this._database);

  Future<Setting> fetch() {
    return _database
        .userReference()
        .get()
        .then((event) => event.data()!.setting!);
  }

  Stream<Setting> stream() => _database
      .userReference()
      .snapshots()
      .map((event) => event.data()?.setting)
      .where((data) => data != null)
      .cast();

  Future<Setting> update(Setting setting) {
    return _database
        .userRawReference()
        .update({UserFirestoreFieldKeys.settings: setting.toJson()}).then(
            (_) => setting);
  }

  void updateWithBatch(WriteBatch batch, Setting setting) {
    batch.set(
      _database.userRawReference(),
      {UserFirestoreFieldKeys.settings: setting.toJson()},
      SetOptions(merge: true),
    );
  }
}
