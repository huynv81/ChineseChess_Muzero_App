import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'common/global.dart';
import 'common/route/route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setSize(Size(appWidth, appHeight));
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
      await windowManager.setResizable(false);
      await windowManager.setMinimizable(true);
      await windowManager.center();
      await windowManager.focus();
      await windowManager.show();
    });
  }

  runApp(GetMaterialApp(
    getPages: AppPages.pages,
    initialRoute: Routes.home,
  ));
}
