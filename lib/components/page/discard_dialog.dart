import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pilll/components/atoms/font.dart';
import 'package:pilll/components/atoms/text_color.dart';

class DiscardDialog extends StatelessWidget {
  final String title;
  final Widget message;
  final List<Widget> actions;

  const DiscardDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.actions,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SvgPicture.asset("images/alert_24.svg", width: 24, height: 24),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: FontType.subTitle.merge(TextColorStyle.main),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 15,
            ),
          ],
          message,
        ],
      ),
      actions: actions,
    );
  }
}

showDiscardDialog(
  BuildContext context, {
  required String title,
  required String message,
  required List<Widget> actions,
}) {
  showDialog(
    context: context,
    builder: (context) => DiscardDialog(
      title: title,
      message:
          Text(message, style: FontType.assisting.merge(TextColorStyle.main)),
      actions: actions,
    ),
  );
}
