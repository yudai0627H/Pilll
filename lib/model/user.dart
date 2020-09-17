import 'dart:async';

import 'package:Pilll/model/setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserNotFound implements Exception {
  toString() {
    return "user not found";
  }
}

extension UserPropertyKeys on String {
  static final anonymouseUserID = "anonymouseUserID";
  static final settings = "settings";
}

class User {
  static final path = "users";
  String get documentID => anonymousUserID;

  final String anonymousUserID;
  Setting setting;

  User._({this.anonymousUserID, this.setting});

  static User _map(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data();
    return User._(
      anonymousUserID: data[UserPropertyKeys.anonymouseUserID],
      setting: Setting(data[UserPropertyKeys.settings]),
    );
  }

  static Future<User> fetch() {
    return FirebaseFirestore.instance
        .collection(User.path)
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((document) {
      if (!document.exists) {
        throw UserNotFound();
      }
      return User._map(document);
    });
  }

  static Future<User> create() {
    return FirebaseFirestore.instance
        .collection(User.path)
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set(
      {
        UserPropertyKeys.anonymouseUserID:
            FirebaseAuth.instance.currentUser.uid,
      },
    ).then((_) {
      return User.fetch();
    });
  }
}

extension UserInterface on User {
  static Future<User> fetchOrCreateUser() {
    return User.fetch().catchError((error) {
      if (error is UserNotFound) {
        return User.create();
      }
      throw FormatException(
          "cause exception when failed fetch and create user for $error");
    });
  }

  Future<void> updateSetting(Setting setting) {
    return FirebaseFirestore.instance.collection(User.path).doc(documentID).set(
        {UserPropertyKeys.settings: setting.settings},
        SetOptions(merge: true)).then((_) => this.setting = setting);
  }
}