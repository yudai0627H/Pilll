import 'dart:async';

import 'package:Pilll/util/datetime/date_compare.dart';
import 'package:Pilll/entity/diary.dart';
import 'package:Pilll/service/diary.dart';
import 'package:Pilll/state/diaries.dart';
import 'package:riverpod/all.dart';

final diariesStoreProvider = StateNotifierProvider(
    (ref) => DiariesStateStore(ref.watch(diaryServiceProvider)));

class DiariesStateStore extends StateNotifier<DiariesState> {
  final DiariesServiceInterface _service;
  DiariesStateStore(this._service) : super(DiariesState()) {
    _subscribe();
  }

  StreamSubscription canceller;
  void _subscribe() {
    canceller?.cancel();
    canceller = _service.subscribe().listen((entities) {
      assert(entities != null, "Diary could not null on subscribe");
      if (entities == null) return;
      state = state.copyWith(entities: entities);
    });
  }

  @override
  void dispose() {
    canceller?.cancel();
    super.dispose();
  }

  Future<void> fetchListForMonth(DateTime dateTimeOfMonth) {
    return _service
        .fetchListForMonth(dateTimeOfMonth)
        .then((entities) => state = state.copyWith(entities: entities));
  }

  Future<void> register(Diary diary) {
    if (state.entities
        .where((element) => isSameDay(diary.date, element.date))
        .isNotEmpty) return Future.error(DiaryAleradyExists(diary));
    return _service.register(diary);
  }

  Future<void> update(Diary diary) {
    if (state.entities
        .where((element) => isSameDay(diary.date, element.date))
        .isEmpty) return Future.error(DiaryIsNotExists(diary));
    return _service.update(diary);
  }
}

class DiaryAleradyExists extends Error {
  final Diary _diary;

  DiaryAleradyExists(this._diary);
  @override
  toString() {
    return "diary already exists for date ${_diary.date}";
  }
}

class DiaryIsNotExists extends Error {
  final Diary _diary;

  DiaryIsNotExists(this._diary);
  @override
  toString() {
    return "diary is not exists for date ${_diary.date}";
  }
}
