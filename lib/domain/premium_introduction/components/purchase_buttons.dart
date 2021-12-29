import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pilll/analytics.dart';
import 'package:pilll/components/page/hud.dart';
import 'package:pilll/domain/premium_introduction/components/annual_purchase_button.dart';
import 'package:pilll/domain/premium_introduction/components/monthly_purchase_button.dart';
import 'package:pilll/domain/premium_introduction/components/purchase_buttons_state.dart';
import 'package:pilll/domain/premium_introduction/premium_complete_dialog.dart';
import 'package:pilll/domain/premium_introduction/premium_introduction_store.dart';
import 'package:pilll/entity/user_error.dart';
import 'package:pilll/error/error_alert.dart';
import 'package:pilll/error/universal_error_page.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseButtons extends HookConsumerWidget {
  final PremiumIntroductionStore store;
  final Offerings offerings;

  const PurchaseButtons({
    Key? key,
    required this.store,
    required this.offerings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseButtonsStateProvider(offerings).notifier);
    final monthlyPackage = state.monthlyPackage;
    final annualPackage = state.annualPackage;

    return Row(
      children: [
        Spacer(),
        if (monthlyPackage != null)
          MonthlyPurchaseButton(
            monthlyPackage: monthlyPackage,
            onTap: (monthlyPackage) async {
              analytics.logEvent(name: "pressed_monthly_purchase_button");
              await _purchase(context, monthlyPackage);
            },
          ),
        SizedBox(width: 16),
        if (annualPackage != null)
          AnnualPurchaseButton(
            annualPackage: annualPackage,
            offeringType: state.offeringType,
            onTap: (annualPackage) async {
              analytics.logEvent(name: "pressed_annual_purchase_button");
              await _purchase(context, annualPackage);
            },
          ),
        Spacer(),
      ],
    );
  }

  _purchase(BuildContext context, Package package) async {
    try {
      // NOTE: Revenuecatからの更新により非同期にUIが変わる。その場合PurchaseButtons自体が隠れてしまい、
      // ShowDialog が 表示されない場合がある。諸々の処理が完了するまでstreamを一回破棄しておく
      store.stopStream();
      HUD.of(context).show();
      final shouldShowCompleteDialog = await store.purchase(package);
      if (shouldShowCompleteDialog) {
        showDialog(
            context: context,
            builder: (_) {
              return PremiumCompleteDialog(onClose: () {
                Navigator.of(context).pop();
              });
            });
      }
    } catch (error) {
      print("caused purchase error for $error");
      if (error is UserDisplayedError) {
        showErrorAlertWithError(context, error);
      } else {
        UniversalErrorPage.of(context).showError(error);
      }
    } finally {
      HUD.of(context).hide();
      // NOTE: Revenuecatからの更新により非同期にUIが変わる。その場合PurchaseButtons自体が隠れてしまい、
      // ShowDialog が 表示されない場合がある。諸々の処理が完了するまでstreamを一回破棄しておく
      store.startStream();
    }
  }
}
