import 'dart:io';

import 'package:chinese_chess_alpha_zero/common/widgets/toast_message.dart';
import 'package:docking/docking.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:macos_ui/macos_ui.dart';

import '../ctrl.dart';

class EnginePulldownButton extends GetView<HomeController> {
  // extends DockingParentArea with DropArea {

  @override
  Widget build(BuildContext context) {
    return MacosPulldownButton(
      // title: "Actions",// icon or text
      // Or provide an icon to use as title:
      // icon: CupertinoIcons.ellipsis_circle,
      icon: CupertinoIcons.ellipsis_circle,
      items: [
        MacosPulldownMenuItem(
          title: const Text('加载ucci引擎'),
          onTap: () {
            controller.onAddNewEngineClicked();
          },
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text('加载内置引擎'),
          onTap: () => debugPrint("todo: 加载内置引擎"),
        ),
        // MacosPulldownMenuItem(
        //   enabled: false,
        //   title: const Text('Export'),
        //   onTap: () => debugPrint("Exporting"),
        // ),
      ],
    );
  }

  @override
  // TODO: implement type
  DockingAreaType get type => throw UnimplementedError();
}
