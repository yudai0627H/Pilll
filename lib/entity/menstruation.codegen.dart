import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pilll/domain/calendar/date_range.dart';
import 'package:pilll/entity/firestore_document_id_escaping_to_json.dart';
import 'package:pilll/entity/firestore_timestamp_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'menstruation.codegen.g.dart';
part 'menstruation.codegen.freezed.dart';

class MenstruationFirestoreKey {
  static const String beginDate = "beginDate";
  static const String deletedAt = "deletedAt";
}

@freezed
class Menstruation with _$Menstruation {
  String? get documentID => id;

  factory Menstruation.fromJson(Map<String, dynamic> json) =>
      _$MenstruationFromJson(json);
  const Menstruation._();

  @JsonSerializable(explicitToJson: true)
  const factory Menstruation({
    @JsonKey(includeIfNull: false, toJson: toNull)
        String? id,
    @JsonKey(
      fromJson: NonNullTimestampConverter.timestampToDateTime,
      toJson: NonNullTimestampConverter.dateTimeToTimestamp,
    )
        required DateTime beginDate,
    @JsonKey(
      fromJson: NonNullTimestampConverter.timestampToDateTime,
      toJson: NonNullTimestampConverter.dateTimeToTimestamp,
    )
        required DateTime endDate,
    @JsonKey(
      fromJson: TimestampConverter.timestampToDateTime,
      toJson: TimestampConverter.dateTimeToTimestamp,
    )
        DateTime? deletedAt,
    @JsonKey(
      fromJson: NonNullTimestampConverter.timestampToDateTime,
      toJson: NonNullTimestampConverter.dateTimeToTimestamp,
    )
        required DateTime createdAt,
    String? healthKitSampleDataUUID,
  }) = _Menstruation;

  DateRange get dateRange => DateRange(beginDate, endDate);
}
