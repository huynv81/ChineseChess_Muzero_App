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

double calc_win_size_by_real_size(double realSize, double winRealSizeRatio) {
  final winSize = winRealSizeRatio * realSize;
  return winSize;
  // return (winSize + 16.5) / devicePixelRatio;
}

double calc_real_size_by_app_size(double appSize, double winRealSizeRatio) {
  final winSize = appSize * devicePixelRatio - 16.5;
  return winSize;
  // return winSize * (1 / winRealSizeRatio);
}

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  // final boardLeftTopDown2edPos = const Offset( 497,302);//左上角向下第二点
  late Offset _leftTopOffSet; //左上角位置距离棋盘左上角的offset
  late double _piecePosOffSet; //相邻2个棋子位置的间距，x、y轴都一样

  late double _width;
  late double _height;
  late double _chessUiWidth;
  // late double _boardWidth; //这个是调整过的棋盘宽度
  // late double _boardHeight; //这个是调整过的棋盘高度
  late double _pieceSize; //这个是调整过的棋子尺寸，宽高一致
  late double realTestRatio;
  late double sizeRatio2;

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    // print('real w: ${_real_app_width}');
    // print('real h: ${_real_app_height}');

    _chessUiWidth = _width * chessUiWidthRatio;

    // 将自己测试的尺寸等比例转换到实际尺寸
    realTestRatio = _width / testWidth;
    _pieceSize = testPieceSize * realTestRatio;
    _leftTopOffSet = Offset(
        realTestRatio * (testLeftTop1stPos.dx - testBoardLeftTopCornerPos.dx),
        realTestRatio * (testLeftTop1stPos.dy - testBoardLeftTopCornerPos.dy));
    _piecePosOffSet =
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
        DockingItem(name: '思考细节', widget: Text("")),
        DockingItem(name: '日志', widget: LogTable())
      ])
    ]));
    Docking docking = Docking(layout: layout);

    // layout
    return Expanded(
      child: Container(
        child: docking,
        color: backgroundStartColor,
      ),
    );
  }

  Widget _getChessWidget() {
    final boardImage =
        SvgPicture.asset(boardPath, width: _chessUiWidth, height: _height);
    return Stack(
      children: [boardImage, ..._getPieceWidgets()],
    );
  }

  _getPieceWidgets() {
    var pieces = [];
    final offsetX = _leftTopOffSet.dx - (_pieceSize / 2);
    final offsetY = _leftTopOffSet.dy - (_pieceSize / 2);

    for (var eachPiece in controller.pieces) {
      final newPiece = Positioned(
        left: offsetX + (eachPiece.col - 1) * (_piecePosOffSet),
        top: offsetY + (eachPiece.row - 1) * (_piecePosOffSet),
        child: SvgPicture.asset(getPieceImagePath(eachPiece.type),
            width: _pieceSize, height: _pieceSize),
      );
      pieces.add(newPiece);
    }
    return pieces;
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
