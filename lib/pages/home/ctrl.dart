/*
 * @Author       : 老董
 * @Date         : 2022-04-29 10:49:11
 * @LastEditors  : 老董
 * @LastEditTime : 2022-05-08 15:28:56
 * @Description  : 用以控制HomeView的control组件
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/global.dart';

class HomeController extends GetxController {
  final _logs = <DataRow>[].obs;
  get logs => _logs;

  final _pieces = <Piece>[].obs;
  get pieces => _pieces;
  // set pieces(value) => _pieces.value = value;

  set logs(value) => _logs.value = value;
  //
  final _animatedContainerHeight = toobarHeight.obs;
  get animatedContainerHeight => _animatedContainerHeight.value;
  set animatedContainerHeight(value) => _animatedContainerHeight.value = value;

  onTest() {
    Get.snackbar("test", "");
  }

  void onToolButtonPressed(String logContent) {
    _logs.add(
      DataRow(
        cells: [
          DataCell(Text(getCurrentTimeString())),
          DataCell(Text(logContent)),
        ],
      ),
    );

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
}
