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
import 'widgets/board_arrow.dart';
import 'widgets/command_bar.dart';
import 'widgets/log_table.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  // final boardLeftTopDown2edPos = const Offset( 497,302);//左上角向下第二点

  late double _width;
  late double _height;
  late double _chessUiWidth;
  // late double _boardWidth; //这个是调整过的棋盘宽度
  // late double _boardHeight; //这个是调整过的棋盘高度
  late double realTestRatio;
  late double sizeRatio2;

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    // print('real w: ${_real_app_width}');
    // print('real h: ${_real_app_height}');

    // _chessUiWidth = _width * chessUiWidthRatio;

    // 将自己测试的尺寸等比例转换到实际尺寸
    realTestRatio = _width / testWidth;
    controller.pieceSize = testPieceSize * realTestRatio;
    controller.leftTopOffSet = Offset(
        realTestRatio * (testLeftTop1stPos.dx - testBoardLeftTopCornerPos.dx),
        realTestRatio * (testLeftTop1stPos.dy - testBoardLeftTopCornerPos.dy));
    controller.pieceGap =
        realTestRatio * (testLeftTop2edPos.dx - testLeftTop1stPos.dx); //x、y轴都一样

    // ui
    final mainUi = Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        Row(
          children: [
            Obx(() => _getChessWidget()),
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

    //Scaffold可提供一些默认theme，所以不能去除
    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) {
          controller.onBoardClicked(details.localPosition);
        },
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          windowManager.startDragging();
        },
        child: mainUi,
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
          DockingItem(name: '日志', widget: LogTable()),
          DockingItem(name: '思考细节', widget: Text("")),
        ])
      ]),
    );
    Docking docking = Docking(layout: layout);

    // layout
    return Expanded(
      child: Container(
        color: backgroundStartColor,
        child: docking,
      ),
    );
  }

  Widget _getArrowWidget() {
    return CustomPaint(
      // child: Container(),
      painter: ArrowPainter(
          controller.arrowMoves, controller.leftTopOffSet, controller.pieceGap),
    );
  }

  Widget _getChessWidget() {
    final boardImage = SvgPicture.asset(boardPath,
        /* width: _chessUiWidth, */ height: _height);
    return Stack(
      children: [
        boardImage,
        ..._getPieceWidgets(),
        _getArrowWidget(),
      ],
    );
  }

  _getPieceWidgets() {
    var pieceWidgets = [];
    final pieceRadius = (controller.pieceSize / 2);
    final pieceOffsetX = controller.leftTopOffSet.dx - pieceRadius;
    final pieceOffsetY = controller.leftTopOffSet.dy - pieceRadius;

    for (var eachPiece in controller.pieces) {
      final xPixel = pieceOffsetX + (eachPiece.col - 1) * (controller.pieceGap);
      final yPixel = pieceOffsetY + (eachPiece.row - 1) * (controller.pieceGap);
      // mask image
      if (eachPiece.maskType() != MaskType.none) {
        final pieceWidget = Positioned(
          left: xPixel,
          top: yPixel,
          child: SvgPicture.asset(getMaskImagePath(eachPiece.maskType()),
              width: controller.pieceSize, height: controller.pieceSize),
        );
        pieceWidgets.add(pieceWidget);
      }
      // piece image
      if (eachPiece.pieceType() != SidePieceType.none) {
        final pieceWidget = Positioned(
          left: xPixel,
          top: yPixel,
          child: SvgPicture.asset(getPieceImagePath(eachPiece.pieceType()),
              width: controller.pieceSize, height: controller.pieceSize),
        );
        pieceWidgets.add(pieceWidget);
      }
    }
    return pieceWidgets;
  }
}

String getMaskImagePath(MaskType sidePieceType) {
  switch (sidePieceType) {
    case MaskType.none:
      throw '查找mask图片时，发现类型为none';
    case MaskType.focused:
      return "${skinPath}mask1.svg";
    case MaskType.moved:
      return "${skinPath}mask2.svg";
  }
}

String getPieceImagePath(SidePieceType sidePieceType) {
  switch (sidePieceType) {
    case SidePieceType.redKing:
      return "${skinPath}rk.svg";
    case SidePieceType.redAdvisor:
      return "${skinPath}ra.svg";
    case SidePieceType.redBishop:
      return "${skinPath}rb.svg";
    case SidePieceType.redKnight:
      return "${skinPath}rn.svg";
    case SidePieceType.redRook:
      return "${skinPath}rr.svg";
    case SidePieceType.redCannon:
      return "${skinPath}rc.svg";
    case SidePieceType.redPawn:
      return "${skinPath}rp.svg";
    // black
    case SidePieceType.blackKing:
      return "${skinPath}bk.svg";
    case SidePieceType.blackAdvisor:
      return "${skinPath}ba.svg";
    case SidePieceType.blackBishop:
      return "${skinPath}bb.svg";
    case SidePieceType.blackKnight:
      return "${skinPath}bn.svg";
    case SidePieceType.blackRook:
      return "${skinPath}br.svg";
    case SidePieceType.blackCannon:
      return "${skinPath}bc.svg";
    case SidePieceType.blackPawn:
      return "${skinPath}bp.svg";
    default:
      throw '错误：未知棋子类型';
  }
}
