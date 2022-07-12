/*
 * @Author       : 老董
 * @Date         : 2022-04-30 11:10:14
 * @LastEditors  : 老董
 * @LastEditTime : 2022-07-12 18:52:21
 * @Description  : ios风格的工具栏
 */

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../../../common/global.dart';
import '../../../common/widgets/ios_dialog_widget.dart';
import '../ctrl.dart';
import 'setting_sheet.dart';

// class CommandBar extends StatefulWidget {
//   const CommandBar({Key? key}) : super(key: key);

//   @override
//   _CommandBarState createState() => _CommandBarState();
// }

// class _CommandBarState extends State<CommandBar> {
// vertical version
// late final int _rotateQuarter;
// final bool vertical;
// CommandBars({Key? key, required this.vertical}) : super(key: key) {
// _rotateQuarter = vertical ? -1 : 0;
// }
//

class CommandBar extends GetView<HomeController> {
  const CommandBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      height: 1,
      automaticallyImplyLeading: false,
      // padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      padding: const EdgeInsets.all(5.0),
      actions: [
        ToolBarIconButton(
          label: "新建棋局",
          icon: const RotatedBox(
            quarterTurns: -1,
            child: MacosIcon(
              CupertinoIcons.add_circled,
            ),
          ),
          onPressed: () => controller.onToolButtonPressed(newChessGameLog),
          showLabel: false,
        ),
        ToolBarIconButton(
          label: "AI",
          icon: const RotatedBox(
            quarterTurns: -1,
            child: Text('AI'),
          ),
          onPressed: () => controller.onToolButtonPressed('AI点击'),
          showLabel: false,
          // tooltipMessage: 'AI设置'
        ),
        ToolBarIconButton(
          label: "设置",
          icon: const RotatedBox(
            quarterTurns: -1,
            child: MacosIcon(
              CupertinoIcons.settings,
            ),
          ),
          onPressed: () => getSettingSheet(context),
          showLabel: false,
        ),
        ToolBarPullDownButton(
          label: "连线器",
          icon: CupertinoIcons.link,
          items: [
            MacosPulldownMenuItem(
              title: const Text("创建新连接方案"),
              onTap: () => debugPrint("Creating new folder..."),
            ),
            MacosPulldownMenuItem(
              title: const Text("已有连接方案（空）"),
              onTap: () => debugPrint("Opening..."),
              enabled: false,
            ),
          ],
        ),
        //
        const ToolBarSpacer(),
        //
        ToolBarIconButton(
          label: "最小化",
          icon: const RotatedBox(
            quarterTurns: -1,
            child: MacosIcon(
              CupertinoIcons.minus,
            ),
          ),
          onPressed: () => windowManager.minimize(), //TODO:失效了？
          showLabel: false,
        ),
        ToolBarIconButton(
          label: "关闭程序",
          icon: const RotatedBox(
            quarterTurns: -1,
            child: MacosIcon(
              CupertinoIcons.xmark_circle,
            ),
          ),
          onPressed: () {
            showIosDialog(
              context,
              "提示",
              "是否退出程序？",
              onYesPressed: () => exit(0),
            );
          },
          showLabel: false,
        ),
      ],
    );
  }
}
