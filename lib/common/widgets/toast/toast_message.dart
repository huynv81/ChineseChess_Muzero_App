import 'package:flutter/cupertino.dart';
import 'package:overlay_support/overlay_support.dart';

import 'toast_style.dart';

void showToast(String message) {
  debugPrint("toast: $message");
  showOverlay((context, t) {
    return CustomAnimationToast(message: message, value: t);
  }, key: ValueKey(message), curve: Curves.decelerate);
}
