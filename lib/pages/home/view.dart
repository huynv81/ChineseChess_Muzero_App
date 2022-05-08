/*
 * @Author       : 老董
 * @Date         : 2022-04-29 10:33:23
 * @LastEditors  : 老董
 * @LastEditTime : 2022-05-08 16:31:08
 * @Description  : 软件的主界面，左侧为棋盘ui，右侧为包括但不限于棋谱列表、局势曲线等窗口的状态ui
 */

import 'package:docking/docking.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../common/global.dart';
import 'ctrl.dart';
import 'widgets/command_bar.dart';
import 'widgets/log_table.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainContent = Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        Row(
          children: [
            _getBoardWidget(),
            _getStateWidget(),
          ],
        ),

        // 工具栏
        Obx(() => MouseRegion(
              onEnter: (value) {
                controller.animatedContainerHeight = toobarHeight;
              },
              onExit: (value) {
                controller.animatedContainerHeight =
                    hideToobarHeight; //留一点空方便鼠标移上去时触发弹出
              },
              cursor: SystemMouseCursors.click, //Cursor type on hover
              child: _getAnimatedCommandBar(),
            )),
      ],
    );

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          windowManager.startDragging();
        },
        child: mainContent,
      ),
    );
  }

  Widget _getAnimatedCommandBar() {
    return RotatedBox(
      quarterTurns: 1,
      child: AnimatedContainer(
        height: controller.animatedContainerHeight, //Animation height control
        width: 400, //Animation width control
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        //
        margin: const EdgeInsets.all(1.0),
        //
        // clipBehavior: Clip.antiAlias, //配合decoration圆角裁剪
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent, width: 1), // added
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: const CommandBar(),
      ),
    );
  }

  Widget _getStateWidget() {
    // docking tab
    DockingLayout layout = DockingLayout(
        root: DockingColumn([
      DockingTabs([
        DockingItem(name: '棋谱', widget: Text("")),
        DockingItem(name: '局势', widget: Text(""))
      ]),
      DockingTabs([
        DockingItem(name: '思考细节', widget: Text("")),
        DockingItem(name: '日志', widget: LogTable())
      ])
    ]));
    Docking docking = Docking(layout: layout);

    // layout
    return SizedBox(
      width: 250,
      child: Container(
        child: docking,
        color: backgroundStartColor,
      ),
    );
  }

  Widget _getBoardWidget() {
    return Expanded(
      child: Image.asset("./assets/skins/woods/board.jpg"),
    );
  }
}
