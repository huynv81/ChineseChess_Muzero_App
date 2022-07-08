import 'package:flutter/cupertino.dart';

void showIosDialog(
  BuildContext context,
  String title,
  String content, {
  Function onYesPressed = defaultCallback,
  Function onNoPressed = defaultCallback,
}) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return getIosDialog(context, title, content,
          yesFunc: onYesPressed, noFunc: onNoPressed);
    },
    barrierDismissible: true,
  );
}

dynamic defaultCallback() {
//  dynamic myCallback(int a,String b) {
}

Widget getIosDialog(BuildContext context, String title, String content,
    {Function yesFunc = defaultCallback, Function noFunc = defaultCallback}) {
  return CupertinoAlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      CupertinoDialogAction(
          child: const Text("是"),
          onPressed: () {
            yesFunc();
            Navigator.of(context).pop();
          }),
      CupertinoDialogAction(
          child: const Text("否"),
          onPressed: () {
            noFunc();
            Navigator.of(context).pop();
          })
    ],
  );
}

Future<dynamic> showAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String cancelActionText,
  required String defaultActionText,
}) async {
  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(cancelActionText),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        CupertinoDialogAction(
          child: Text(defaultActionText),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}
