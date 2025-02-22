import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:pilll/database/database.dart';
import 'package:pilll/domain/premium_function_survey/premium_function_survey_element_type.dart';
import 'package:pilll/entity/package.codegen.dart';
import 'package:pilll/entity/premium_function_survey.codegen.dart';
import 'package:pilll/entity/setting.codegen.dart';
import 'package:pilll/entity/user.codegen.dart';
import 'package:pilll/util/datetime/day.dart';
import 'package:pilll/util/shared_preference/keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userDatastoreProvider =
    Provider((ref) => UserDatastore(ref.watch(databaseProvider)));

final userStreamProvider =
    StreamProvider((ref) => ref.watch(userDatastoreProvider).stream());

class UserDatastore {
  final DatabaseConnection _database;
  UserDatastore(this._database);

  Future<User> fetchOrCreate(String uid) async {
    debugPrint("call fetchOrCreate for $uid");
    final user = await fetch().catchError((error) {
      if (error is UserNotFound) {
        return _create(uid).then((_) => fetch());
      }
      throw FormatException(
          "cause exception when failed fetch and create user. error: $error, stackTrace: ${StackTrace.current.toString()}");
    });
    return user;
  }

  Future<User> fetch() async {
    debugPrint("call fetch for ${_database.userID}");

    final document = await _database.userReference().get();
    if (!document.exists) {
      debugPrint("user does not exists ${_database.userID}");
      throw UserNotFound();
    }

    return document.data()!;
  }

  Stream<User> stream() =>
      _database.userReference().snapshots().map((event) => event.data()!);

  Future<void> updatePurchaseInfo({
    required bool? isActivated,
    required String? entitlementIdentifier,
    required String? premiumPlanIdentifier,
    required String purchaseAppID,
    required List<String> activeSubscriptions,
    required String? originalPurchaseDate,
  }) async {
    await _database.userRawReference().set({
      if (isActivated != null) UserFirestoreFieldKeys.isPremium: isActivated,
      UserFirestoreFieldKeys.purchaseAppID: purchaseAppID
    }, SetOptions(merge: true));
    final privates = {
      if (premiumPlanIdentifier != null)
        UserPrivateFirestoreFieldKeys.latestPremiumPlanIdentifier:
            premiumPlanIdentifier,
      if (originalPurchaseDate != null)
        UserPrivateFirestoreFieldKeys.originalPurchaseDate:
            originalPurchaseDate,
      if (activeSubscriptions.isNotEmpty)
        UserPrivateFirestoreFieldKeys.activeSubscriptions: activeSubscriptions,
      if (entitlementIdentifier != null)
        UserPrivateFirestoreFieldKeys.entitlementIdentifier:
            entitlementIdentifier,
    };
    if (privates.isNotEmpty) {
      await _database
          .userPrivateRawReference()
          .set({...privates}, SetOptions(merge: true));
    }
  }

  Future<void> syncPurchaseInfo({
    required bool isActivated,
  }) async {
    await _database.userRawReference().set({
      UserFirestoreFieldKeys.isPremium: isActivated,
    }, SetOptions(merge: true));
  }

  Future<void> deleteSettings() {
    return _database
        .userReference()
        .update({UserFirestoreFieldKeys.settings: FieldValue.delete()});
  }

  Future<void> setFlutterMigrationFlag() {
    return _database.userRawReference().set(
      {UserFirestoreFieldKeys.migratedFlutter: true},
      SetOptions(merge: true),
    );
  }

  Future<void> _create(String uid) async {
    debugPrint("call create for $uid");
    final sharedPreferences = await SharedPreferences.getInstance();
    final anonymousUserID =
        sharedPreferences.getString(StringKey.lastSignInAnonymousUID);
    return _database.userRawReference().set(
      {
        if (anonymousUserID != null)
          UserFirestoreFieldKeys.anonymousUserID: anonymousUserID,
        UserFirestoreFieldKeys.userIDWhenCreateUser: uid,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> registerRemoteNotificationToken(String? token) {
    debugPrint("token: $token");
    return _database.userPrivateRawReference().set(
      {UserPrivateFirestoreFieldKeys.fcmToken: token},
      SetOptions(merge: true),
    );
  }

  Future<void> linkApple(String? email) async {
    await _database.userRawReference().set({
      UserFirestoreFieldKeys.isAnonymous: false,
    }, SetOptions(merge: true));
    return _database.userPrivateRawReference().set({
      if (email != null) UserPrivateFirestoreFieldKeys.appleEmail: email,
      UserPrivateFirestoreFieldKeys.isLinkedApple: true,
    }, SetOptions(merge: true));
  }

  Future<void> linkGoogle(String? email) async {
    await _database.userRawReference().set({
      UserFirestoreFieldKeys.isAnonymous: false,
    }, SetOptions(merge: true));
    return _database.userPrivateRawReference().set({
      if (email != null) UserPrivateFirestoreFieldKeys.googleEmail: email,
      UserPrivateFirestoreFieldKeys.isLinkedGoogle: true,
    }, SetOptions(merge: true));
  }

  Future<void> endInitialSetting(Setting setting) {
    final settingForTrial = setting.copyWith(
      pillSheetAppearanceMode: PillSheetAppearanceMode.date,
      isAutomaticallyCreatePillSheet: true,
    );

    return _database.userRawReference().set({
      UserFirestoreFieldKeys.isTrial: true,
      UserFirestoreFieldKeys.beginTrialDate: now(),
      UserFirestoreFieldKeys.trialDeadlineDate:
          now().add(const Duration(days: 30)),
      UserFirestoreFieldKeys.settings: settingForTrial.toJson(),
      UserFirestoreFieldKeys.hasDiscountEntitlement: true,
    }, SetOptions(merge: true));
  }

  Future<void> sendPremiumFunctionSurvey(
      List<PremiumFunctionSurveyElementType> elements, String message) async {
    final PremiumFunctionSurvey premiumFunctionSurvey = PremiumFunctionSurvey(
      elements: elements,
      message: message,
    );
    return _database.userPrivateRawReference().set({
      UserPrivateFirestoreFieldKeys.premiumFunctionSurvey:
          premiumFunctionSurvey.toJson()
    }, SetOptions(merge: true));
  }

  // NOTE: 下位互換のために一時的にhasDiscountEntitlementをtrueにしていくスクリプト。
  // サーバー側での制御が無駄になるけど、理屈ではこれで生合成が取れる
  Future<void> temporarySyncronizeDiscountEntitlement(User user) async {
    final discountEntitlementDeadlineDate =
        user.discountEntitlementDeadlineDate;
    final bool hasDiscountEntitlement;
    if (discountEntitlementDeadlineDate == null) {
      hasDiscountEntitlement = true;
    } else {
      hasDiscountEntitlement = !now().isAfter(discountEntitlementDeadlineDate);
    }
    return _database.userRawReference().set({
      UserFirestoreFieldKeys.hasDiscountEntitlement: hasDiscountEntitlement,
    }, SetOptions(merge: true));
  }
}

extension SaveUserLaunchInfo on UserDatastore {
  saveUserLaunchInfo(User user) {
    unawaited(_saveStats(user));
  }

  Future<void> _saveStats(User user) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    // Stats
    final lastLoginVersion =
        await PackageInfo.fromPlatform().then((value) => value.version);
    String? beginVersion = sharedPreferences.getString(StringKey.beginVersion);
    if (beginVersion == null) {
      final v = lastLoginVersion;
      await sharedPreferences.setString(StringKey.beginVersion, v);
      beginVersion = v;
    }

    // timezone
    final now = DateTime.now().toLocal();
    final timeZoneName = now.timeZoneName;
    final timeZoneOffset = now.timeZoneOffset;
    final timeZoneDatabaseName = await FlutterNativeTimezone.getLocalTimezone();

    // Package
    final packageInfo = await PackageInfo.fromPlatform();
    final os = Platform.operatingSystem;
    final package = Package(
        latestOS: os,
        appName: packageInfo.appName,
        buildNumber: packageInfo.buildNumber,
        appVersion: packageInfo.version);

    // UserIDs
    final userID = user.id!;
    List<String> userDocumentIDSets = [...user.userDocumentIDSets];
    if (!userDocumentIDSets.contains(userID)) {
      userDocumentIDSets.add(userID);
    }
    final lastSignInAnonymousUID =
        sharedPreferences.getString(StringKey.lastSignInAnonymousUID);
    List<String> anonymousUserIDSets = [...user.anonymousUserIDSets];
    if (lastSignInAnonymousUID != null &&
        !anonymousUserIDSets.contains(lastSignInAnonymousUID)) {
      anonymousUserIDSets.add(lastSignInAnonymousUID);
    }
    final firebaseCurrentUserID =
        firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    List<String> firebaseCurrentUserIDSets = [
      ...user.firebaseCurrentUserIDSets
    ];
    if (firebaseCurrentUserID != null &&
        !firebaseCurrentUserIDSets.contains(firebaseCurrentUserID)) {
      firebaseCurrentUserIDSets.add(firebaseCurrentUserID);
    }

    return _database.userRawReference().set({
      // Shortcut property for backend
      "lastLoginAt": now,
      // Stats
      "stats": {
        "lastLoginAt": now,
        "beginVersion": beginVersion,
        "lastLoginVersion": lastLoginVersion,
      },
      "timezone": {
        "name": timeZoneName,
        "databaseName": timeZoneDatabaseName,
        "offsetInHours": timeZoneOffset.inHours,
        "offsetIsNegative": timeZoneOffset.isNegative,
      },
      // Package
      UserFirestoreFieldKeys.packageInfo: package.toJson(),

      // UserIDs
      UserFirestoreFieldKeys.userDocumentIDSets: userDocumentIDSets,
      UserFirestoreFieldKeys.firebaseCurrentUserIDSets:
          firebaseCurrentUserIDSets,
      UserFirestoreFieldKeys.anonymousUserIDSets: anonymousUserIDSets,
    }, SetOptions(merge: true));
  }
}
