/*
 * @Author       : 老董
 * @Date         : 2022-04-29 10:49:11
 * @LastEditors  : 老董
 * @LastEditTime : 2022-05-08 15:28:56
 * @Description  : 用以控制HomeView的control组件
 */

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/global.dart';

class HomeController extends GetxController {
  final _logs = <DataRow>[].obs;
  get logs => _logs;

  final _selectedPoses = <FocusedPiece>[].obs;
  get selectedPoses => _selectedPoses;

  final _pieces = <Piece>[].obs; //该list中是当前需要被展示的所有棋子信息
  get pieces => _pieces;
  // set pieces(value) => _pieces.value = value;

  set logs(value) => _logs.value = value;
  //
  final _animatedContainerHeight = toobarHeight.obs;
  get animatedContainerHeight => _animatedContainerHeight.value;
  set animatedContainerHeight(value) => _animatedContainerHeight.value = value;

  // real chess size
  var leftTopOffSet = Offset(0.0, 0.0); //左上角棋子位置距离棋盘左上角的offset
  var pieceGap = 0.0; //相邻2个棋子中心位置的间距，x、y轴都一样
  var pieceSize = 0.0; //这个是调整过的棋子尺寸，宽高一致

  onTest() {
    Get.snackbar("test", "");
  }

  void onToolButtonPressed(String logContent) {
    addLog(logContent);

    //
    _pieces.clear();
    for (int i = 0; i < ORIG_BOARD_ARRAY.length; i++) {
      final pieceNum = ORIG_BOARD_ARRAY[i];
      var pieceType = pieceMap[pieceNum];
      if (pieceType != null) {
        final origRow = (i + 1) ~/ 16;
        final yu = (i + 1) % 16;
        if (yu == 0) {
          _pieces.add(Piece(pieceType, origRow - 3, 16 - 3));
        } else {
          _pieces.add(Piece(pieceType, origRow + 1 - 3, yu - 3));
        }
      }
    }
  }

  void addLog(String logContent) {
    _logs.insert(
      0,
      DataRow(
        cells: [
          DataCell(Text(getCurrentTimeString())),
          DataCell(Text(logContent)),
        ],
      ),
    );
  }

  void onMouseClick(Offset localPosition) {
    final nearestPos = getNearestPos(localPosition);
    if (nearestPos[0] != null && nearestPos[1] != null) {
      if (_selectedPoses.length >= 3) {
        _selectedPoses.removeAt(0);
      }
      _selectedPoses.add(FocusedPiece(nearestPos[0]!, nearestPos[1]!));

      addLog("Mouse clicked 行${nearestPos[0]}列${nearestPos[1]}");
    }
  }

  // 若鼠标所选位置没有（空）棋子，则返回null
  List<int?> getNearestPos(Offset localPosition) {
    int? finalRow;
    int? finalCol;
    const safeRatio = 0.9;
    // x
    final xCorrectLen = localPosition.dx - leftTopOffSet.dx;
    if (xCorrectLen <= 0) {
      finalCol = 1;
    } else {
      final col = xCorrectLen ~/ pieceGap;
      final xModNum = xCorrectLen % pieceGap;
      if (xModNum == 0) {
        finalCol = col + 1;
      } else {
        if (xModNum < (pieceSize / 2) * safeRatio) {
          finalCol = col + 1;
        } else if (xModNum > (pieceGap - pieceSize / 2 * safeRatio)) {
          finalCol = col + 2;
        }
      }
    }

    // y
    final yCorrectLen = localPosition.dy - leftTopOffSet.dy;
    if (yCorrectLen <= 0) {
      finalRow = 1;
    } else {
      final row = yCorrectLen ~/ pieceGap;
      final yModNum = yCorrectLen % pieceGap;
      if (yModNum == 0) {
        finalRow = row + 1;
      } else {
        if (yModNum < (pieceSize / 2) * safeRatio) {
          finalRow = row + 1;
        } else if (yModNum > (pieceGap - pieceSize / 2 * safeRatio)) {
          finalRow = row + 2;
        }
      }
    }
    return [finalRow, finalCol];
  }
}
