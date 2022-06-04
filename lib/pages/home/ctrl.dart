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
import '../../ffi.dart';

class HomeController extends GetxController {
  final _logs = <DataRow>[].obs;

  final masks = <Piece>[]; //添加了mask的piece引用列表

  get logs => _logs;
  set logs(value) => _logs.value = value;

  final RxList<Piece> _pieces = <Piece>[].obs;
  //该list中是当前需要被展示的所有棋子信息
  get pieces => _pieces;

  HomeController() {
    for (var i = 0; i < boardRowCount * boardColCount; i++) {
      _pieces.add(Piece(SidePieceType.none, 1, 1));
    }
  }

  // set pieces(value) => _pieces.value = value;
  Piece? _focusedPieceRef; //被鼠标选中的棋子,指向_pieces中某piece元素的引用

  //
  var _currentPlayer = Player.none;
  //
  final _animatedContainerHeight = toobarHeight.obs;
  get animatedContainerHeight => _animatedContainerHeight.value;
  set animatedContainerHeight(value) => _animatedContainerHeight.value = value;

  // real chess size
  var leftTopOffSet = Offset(0.0, 0.0); //左上角棋子位置距离棋盘左上角的offset
  var pieceGap = 0.0; //相邻2个棋子中心位置的间距，x、y轴都一样
  var pieceSize = 0.0; //这个是调整过的棋子尺寸，宽高一致

  void onToolButtonPressed(String logContent) {
    addLog(logContent);
    if (logContent == newChessGameLog) {
      //TODO: move to rust
      var correctRow = 0;
      var correctCol = 0;
      for (int i = 0; i < ORIG_BOARD_ARRAY.length; i++) {
        final origRow = (i + 1) ~/ 16;
        final modNum = (i + 1) % 16;
        if (modNum == 0) {
          correctRow = origRow - 3;
          correctCol = 16 - 3;
        } else {
          correctRow = origRow + 1 - 3;
          correctCol = modNum - 3;
        }
        final inBoardRowRange = correctRow >= 1 && correctRow <= boardRowCount;
        final inBoardColRange = correctCol >= 1 && correctCol <= boardColCount;
        if (inBoardRowRange && inBoardColRange) {
          final pieceTypeNum = ORIG_BOARD_ARRAY[i];
          var pieceType = pieceMap[pieceTypeNum];
          if (pieceType != null) {
            final index = (correctRow - 1) * boardColCount + correctCol - 1;
            _pieces[index] = (Piece(pieceType, correctRow, correctCol));
          }
        }
      }

      // 必要的初始化
      _currentPlayer = Player.red;
      _focusedPieceRef = null;
    }
  }

  void _switchPlayer() {
    switch (_currentPlayer) {
      case Player.none:
        throw '切换玩家时发现None';
      case Player.red:
        _currentPlayer = Player.black;
        break;
      case Player.black:
        _currentPlayer = Player.red;
        break;
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

  Future<void> onClicked(Offset localPosition) async {
    // 是否为有效点击位
    final validClickedPieceRef = getValidClickedPos(localPosition);
    if (validClickedPieceRef == null) {
      //NOTE：为null仅代表该位置非有效点击坐标，不包括该位置为空棋子的情况
      return;
    }
    addLog("有效点击：行${validClickedPieceRef.row}列${validClickedPieceRef.col}");

    if (_focusedPieceRef != null) {
      // ASSERT
      if (_currentPlayer != _focusedPieceRef!.player()) {
        throw '当前玩家和被选中的棋子的不是同一玩家';
      }
      //
      if (validClickedPieceRef.player() == _currentPlayer) {
        _focusedPieceRef!.setMaskType(MaskType.none);
        _focusedPieceRef = validClickedPieceRef;
        _focusedPieceRef!.setMaskType(MaskType.focused);
        _pieces.refresh();
      } else {
        var flag =
            await isMoveOrEatable(_focusedPieceRef!, validClickedPieceRef);
        if (flag) {
          // 移动棋子
          validClickedPieceRef.setPiece(_focusedPieceRef!.pieceType());
          _focusedPieceRef!.setPiece(SidePieceType.none);

          // 将之前masked的边框全部清除掉
          for (var eachMaskedPiece in masks) {
            eachMaskedPiece.setMaskType(MaskType.none);
          }
          masks.clear();

          // 设置新移动棋子的mask并加入masks
          _focusedPieceRef!.setMaskType(MaskType.moved);
          validClickedPieceRef.setMaskType(MaskType.moved);
          masks.add(_focusedPieceRef!);
          masks.add(validClickedPieceRef);

          _focusedPieceRef = null;

          _switchPlayer();
          _pieces.refresh();
        }
      }
    } else if (validClickedPieceRef.player() == _currentPlayer) {
      validClickedPieceRef.setMaskType(MaskType.focused);
      _focusedPieceRef = validClickedPieceRef;
      _pieces.refresh();
    }
  }

  Future<bool> isMoveOrEatable(Piece srcPiece, Piece dstPiece) async {
    if (_currentPlayer == Player.none) {
      throw '错误：玩家不该是none';
    }
    if (srcPiece.player() != _currentPlayer) {
      throw '错误：带检查的起始位置棋子非当前玩家';
    }
    if (dstPiece.player() == _currentPlayer) {
      throw '错误：带检查的目标位置棋子是当前玩家';
    }

// TODO：rust
    // var output = await api.add2UnsignedValue(v1: 1, v2: 5);
    return true;
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

  Piece? getValidClickedPos(Offset localPosition) {
    final nearestPos = getNearestPos(localPosition);

    var row = nearestPos[0];
    var col = nearestPos[1];
    if (row != null && col != null) {
      // 从_pieces中返回该位置的piece引用
      for (var piece in _pieces) {
        if (piece.row == row && piece.col == col) {
          return piece;
        }
      }
    }
    return null;
  }
}
