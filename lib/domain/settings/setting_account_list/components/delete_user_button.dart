import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pilll/analytics.dart';
import 'package:pilll/auth/apple.dart';
import 'package:pilll/auth/google.dart';
import 'package:pilll/components/atoms/buttons.dart';
import 'package:pilll/components/atoms/font.dart';
import 'package:pilll/components/atoms/text_color.dart';
import 'package:pilll/components/page/discard_dialog.dart';
import 'package:pilll/error/error_alert.dart';
import 'package:pilll/error_log.dart';
import 'package:pilll/router/router.dart';

class DeleteUserButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 54),
      child: AlertButton(
        onPressed: () async {
          showDiscardDialog(
            context,
            title: "ユーザー情報が削除されます",
            message: "退会をするとすべてデータが削除され、二度と同じアカウントでログインができなくなります。",
            actions: [
              AlertButton(
                text: "キャンセル",
                onPressed: () async {
                  analytics.logEvent(name: "cancel_delete_user");
                  Navigator.of(context).pop();
                },
              ),
              AlertButton(
                text: "退会する",
                onPressed: () async {
                  analytics.logEvent(name: "pressed_delete_user_button");
                  await _delete(context);
                },
              ),
            ],
          );
        },
        text: "退会する",
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      showDialog(
        context: context,
        builder: (context) {
          return _CompletedDialog(
            onClose: () async {
              await AppRouter.routeToInitialSetting(context);
            },
          );
        },
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      if (error.code == "requires-recent-login") {
        showDiscardDialog(
          context,
          title: "再ログインしてください",
          message: "退会前に本人確認のために再ログインをしてください。再ログイン後、自動的に退会処理が始まります",
          actions: [
            AlertButton(
              text: "キャンセル",
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            AlertButton(
              text: "再ログイン",
              onPressed: () async {
                if (isLinkedApple()) {
                  await appleReauthentification();
                } else if (isLinkedGoogle()) {
                  await googleReauthentification();
                } else {
                  errorLogger.log("it is not cooperate account");
                  exit(1);
                }
                Navigator.of(context).pop();
                await _delete(context);
              },
            ),
          ],
        );
      } else {
        errorLogger.recordError(error, stackTrace);
        showErrorAlert(context, message: error.toString());
      }
    } catch (error) {
      showErrorAlert(context, message: error.toString());
    }
  }
}

class _CompletedDialog extends StatelessWidget {
  final Future<void> Function() onClose;

  const _CompletedDialog({Key? key, required this.onClose}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      content: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "退会しました",
              style: TextStyle(
                color: TextColor.main,
                fontFamily: FontFamily.japanese,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              "初期設定画面に移動します。新しいアカウントとして引き続きご利用になる場合は再度設定をお願いいたします",
              style: TextStyle(
                color: TextColor.main,
                fontFamily: FontFamily.japanese,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await onClose();
              },
              text: "OK",
            ),
          ],
        ),
      ),
    );
  }
}
