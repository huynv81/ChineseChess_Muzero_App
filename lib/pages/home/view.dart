/*
 * @Author       : 老董
 * @Date         : 2022-04-29 10:33:23
 * @LastEditors  : 老董
 * @LastEditTime : 2022-05-08 16:31:08
 * @Description  : 软件的主界面，左侧为棋盘ui，右侧为包括但不限于棋谱列表、局势曲线等窗口的状态ui
 */
import 'dart:io';

import 'package:docking/docking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../common/global.dart';
import 'ctrl.dart';
import 'widgets/command_bar.dart';
import 'widgets/log_table.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  // final boardLeftTopDown2edPos = const Offset( 497,302);//左上角向下第二点
  late Offset _leftTopOffSet; //左上角位置距离棋盘左上角的offset
  late double _piecePosOffSet; //相邻2个棋子位置的间距，x、y轴都一样
  late double _pieceSize; //这个是调整过的棋子尺寸，宽高一致
  late double sizeRatio;
  Widget build(BuildContext context) {
    var actual_width = MediaQuery.of(context).size.width;
    var actual_height = MediaQuery.of(context).size.height;
    sizeRatio = actual_width / winWidth;
    // final heightRatio = actual_height / winHeight;
    // size
    _pieceSize = pieceSize * sizeRatio;
    _leftTopOffSet = Offset(
        sizeRatio * (leftTop1stPos.dx - boardLeftTopCornerPos.dx),
        sizeRatio * (leftTop1stPos.dy - boardLeftTopCornerPos.dy));
    _piecePosOffSet =
        sizeRatio * (leftTop2edPos.dx - leftTop1stPos.dx); //x、y轴都一样

    // await getChessImageSize();

    // ui
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
    final boardImage =
        SvgPicture.asset(boardPath, width: boardWidth, height: boardHeight);
    // final boardImage = Image.asset(
    //   boardPath,
    // );

    return Expanded(
      child: Stack(
        children: [boardImage, ..._getPieceWidgets()],
      ),
    );
  }

  _getPieceWidgets() {
    var pieces = [];
    final offsetX = _leftTopOffSet.dx - (_pieceSize / 2);
    final offsetY = _leftTopOffSet.dy - (_pieceSize / 2);
    for (var col = 0; col < 9; col++) {
      for (var row = 0; row < 10; row++) {
        final newPiece = Positioned(
          left: offsetX + col * (_piecePosOffSet),
          top: offsetY + row * (_piecePosOffSet),
          child: SvgPicture.asset(samplePiecePath,
              width: _pieceSize, height: _pieceSize),
        );
        pieces.add(newPiece);
      }
    }
    return pieces;
  }
}
