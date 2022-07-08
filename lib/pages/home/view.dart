/*
 * @Author       : 老董
 * @Date         : 2022-04-29 10:33:23
 * @LastEditors  : 老董
 * @LastEditTime : 2022-06-14 10:05:55
 * @Description  : 软件的主界面，左侧为棋盘ui，右侧为包括但不限于棋谱列表、局势曲线等窗口的状态ui
 */

import 'package:dashed_rect/dashed_rect.dart';
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
    // debugPrint('real w: ${_real_app_width}');
    // debugPrint('real h: ${_real_app_height}');

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
            _getChessWidget(),
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
          controller.onWindowClicked(details.localPosition);
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
          DockingItem(name: '棋谱', widget: const Text("")),
          DockingItem(name: '局势', widget: const Text(""))
        ]),
        DockingTabs([
          DockingItem(name: '日志', widget: const LogTable()),
          DockingItem(name: '思考细节', widget: const Text("")),
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

    for (Piece eachPiece in controller.pieces) {
      final xPixel = pieceOffsetX + (eachPiece.col - 1) * (controller.pieceGap);
      final yPixel = pieceOffsetY + (eachPiece.row - 1) * (controller.pieceGap);

      pieceWidgets.add(GetBuilder<HomeController>(
        id: eachPiece.index,
        builder: (_) {
          // debugPrint("重建id:${eachPiece.index}");
          final mask = eachPiece.maskType();
          final pieceType = eachPiece.pieceType();
          return Positioned(
            left: xPixel,
            top: yPixel,
            child: DashedRect(
              gap: !controller.gameStarted || mask == MaskType.none
                  ? 50 //该数超过30后不会显示线框
                  : mask == MaskType.focused
                      ? 0.08 //数字越小越接近实线，0.08刚刚好！
                      : 3, //虚线框
              strokeWidth: 1.5,
              color: Colors.deepPurpleAccent,
              // color: Colors.purple,
              child: pieceType == SidePieceType.none
                  ? SizedBox(
                      width: controller.pieceSize,
                      height: controller.pieceSize,
                    )
                  : SvgPicture.asset(
                      getPieceImagePath(eachPiece.pieceType()),
                      width: controller.pieceSize,
                      height: controller.pieceSize,
                    ),
            ),
          );
        },
      ));
    }
    return pieceWidgets;
  }

  Border getWhiteBorderCircle() {
    return Border.all(
        color: const Color.fromARGB(137, 5, 13, 107),
        width: 2,
        style: BorderStyle.solid);
  }

  Border getGreenBorderCircle() {
    return Border.all(
        color: const Color.fromARGB(137, 2, 130, 51),
        width: 2,
        style: BorderStyle.solid);
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
