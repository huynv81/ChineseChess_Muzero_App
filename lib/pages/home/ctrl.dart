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
import 'widgets/board_arrow.dart';

class HomeController extends GetxController {
  final _logs = <DataRow>[].obs;

  final masks = <Piece>[]; //添加了mask的piece引用列表

  get logs => _logs;
  set logs(value) => _logs.value = value;

  //该list中是当前需要被展示的所有棋子信息
  final pieces = <Piece>[];

  // 需要绘制箭头的棋步
  final RxList<ChessMove> _arrowMoves = <ChessMove>[].obs;
  get arrowMoves => _arrowMoves;

  HomeController() {
    for (var i = 0; i < boardRowCount * boardColCount; i++) {
      pieces.add(Piece(SidePieceType.none, i));
    }

    for (var i = 0; i < 2; i++) {
      _arrowMoves.add(ChessMove(
        srcRow: 1,
        srcCol: 1,
        dstRow: 1,
        dstCol: 1,
        player: _player,
      ));
    }
  }

  // set pieces(value) => _pieces.value = value;
  Piece? _focusedPieceRef; //被鼠标选中的棋子,指向_pieces中某piece元素的引用

  //
  var _player = Player.none;
  //
  final _animatedContainerHeight = toobarHeight.obs;
  get animatedContainerHeight => _animatedContainerHeight.value;
  set animatedContainerHeight(value) => _animatedContainerHeight.value = value;

  // real chess size
  var leftTopOffSet = Offset(0.0, 0.0); //左上角棋子位置距离棋盘左上角的offset
  var pieceGap = 0.0; //相邻2个棋子中心位置的间距，x、y轴都一样
  var pieceSize = 0.0; //这个是调整过的棋子尺寸，宽高一致

  Future<void> onToolButtonPressed(String logContent) async {
    addLog(logContent);
    final indexes = <int>[];

    switch (logContent) {
      case newChessGameLog:
        var correctRow = 0;
        var correctCol = 0;
        final origBoardArray = await api.getOrigBoard();
        for (int i = 0; i < origBoardArray.length; i++) {
          final origRow = (i + 1) ~/ 16;
          final modNum = (i + 1) % 16;
          if (modNum == 0) {
            correctRow = origRow - 3;
            correctCol = 16 - 3;
          } else {
            correctRow = origRow + 1 - 3;
            correctCol = modNum - 3;
          }
          final inBoardRowRange =
              correctRow >= 1 && correctRow <= boardRowCount;
          final inBoardColRange =
              correctCol >= 1 && correctCol <= boardColCount;
          if (inBoardRowRange && inBoardColRange) {
            final pieceTypeNum = origBoardArray[i];
            var pieceType = pieceMap[pieceTypeNum];
            if (pieceType != null) {
              final index = (correctRow - 1) * boardColCount + correctCol - 1;
              pieces[index].setPieceType(pieceType);
              pieces[index].setMaskType(MaskType.none);

              indexes.add(index);
            }
          }
        }

        // 必要的初始化
        _player = Player.red;
        _focusedPieceRef = null;

        // 后台数据更新
        await _updateBackData();
        //
        update(indexes);

        break;
      default: //测试用
        final arrow1 = ChessMove(
            srcRow: 10, srcCol: 9, dstRow: 1, dstCol: 9, player: Player.red);
        final arrow2 = ChessMove(
            srcRow: 9, srcCol: 8, dstRow: 1, dstCol: 9, player: Player.black);
        final arrow3 = ChessMove(
            srcRow: 10, srcCol: 8, dstRow: 8, dstCol: 7, player: Player.black);
        final arrow4 = ChessMove(
            srcRow: 1, srcCol: 2, dstRow: 3, dstCol: 4, player: Player.black);
        final arrow5 = ChessMove(
            srcRow: 1, srcCol: 7, dstRow: 3, dstCol: 5, player: Player.black);
        final arrow6 = ChessMove(
            srcRow: 8, srcCol: 8, dstRow: 8, dstCol: 5, player: Player.black);
        final arrow7 = ChessMove(
            srcRow: 8, srcCol: 5, dstRow: 5, dstCol: 5, player: Player.red);
        final arrow8 = ChessMove(
            srcRow: 10, srcCol: 4, dstRow: 9, dstCol: 5, player: Player.red);
        final arrow9 = ChessMove(
            srcRow: 8, srcCol: 6, dstRow: 9, dstCol: 5, player: Player.black);
        final arrow10 = ChessMove(
            srcRow: 2, srcCol: 1, dstRow: 2, dstCol: 4, player: Player.red);
        final arrow11 = ChessMove(
            srcRow: 2, srcCol: 1, dstRow: 2, dstCol: 8, player: Player.red);
        _arrowMoves.addAll([
          arrow1,
          arrow2,
          arrow3,
          arrow4,
          arrow5,
          arrow6,
          arrow7,
          arrow8,
          arrow9,
          arrow10,
          arrow11,
        ]);
      // _arrowMoves.refresh();

      //   final redMoveStr = await api.getRandomValidMove('r');
      //   final blackMoveStr = await api.getRandomValidMove('b');
      // // TODO: how to draw line with arrow

    }

    // if (logContent == newChessGameLog) {
    //   var correctRow = 0;
    //   var correctCol = 0;
    //   final origBoardArray = await api.getOrigBoard();
    //   for (int i = 0; i < origBoardArray.length; i++) {
    //     final origRow = (i + 1) ~/ 16;
    //     final modNum = (i + 1) % 16;
    //     if (modNum == 0) {
    //       correctRow = origRow - 3;
    //       correctCol = 16 - 3;
    //     } else {
    //       correctRow = origRow + 1 - 3;
    //       correctCol = modNum - 3;
    //     }
    //     final inBoardRowRange = correctRow >= 1 && correctRow <= boardRowCount;
    //     final inBoardColRange = correctCol >= 1 && correctCol <= boardColCount;
    //     if (inBoardRowRange && inBoardColRange) {
    //       final pieceTypeNum = origBoardArray[i];
    //       var pieceType = pieceMap[pieceTypeNum];
    //       if (pieceType != null) {
    //         final index = (correctRow - 1) * boardColCount + correctCol - 1;
    //         _pieces[index] = (Piece(pieceType, correctRow, correctCol));
    //       }
    //     }
    //   }

    // // 必要的初始化
    // _currentPlayer = Player.red;
    // _focusedPieceRef = null;

    // // 后台数据更新
    // await _updateBackData();
    // }
  }

  void _switchPlayer() async {
    switch (_player) {
      case Player.none:
        throw '切换玩家时发现None';
      case Player.red:
        _player = Player.black;
        break;
      case Player.black:
        _player = Player.red;
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

  Future<void> onBoardClicked(Offset localPosition) async {
    // 是否为有效点击位
    final validClickedPieceRef = getChessPosFromOffset(localPosition);
    if (validClickedPieceRef == null) {
      //NOTE：为null仅代表该位置非有效点击坐标，不包括该位置为空棋子的情况
      return;
    }
    addLog("有效点击：行${validClickedPieceRef.row}列${validClickedPieceRef.col}");

    if (_focusedPieceRef != null) {
      // ASSERT
      if (_player != _focusedPieceRef!.player()) {
        throw '当前玩家和被选中的棋子的不是同一玩家';
      }
      //
      if (validClickedPieceRef.player() == _player) {
        _focusedPieceRef!.setMaskType(MaskType.none);
        validClickedPieceRef.setMaskType(MaskType.focused);
        update([_focusedPieceRef!.index, validClickedPieceRef.index]);
        _focusedPieceRef = validClickedPieceRef;
      } else if (await isMoveOrEatable(
          _focusedPieceRef!, validClickedPieceRef)) {
        // 移动棋子
        validClickedPieceRef.setPieceType(_focusedPieceRef!.pieceType());
        _focusedPieceRef!.setPieceType(SidePieceType.none);

        // 将之前masked的边框全部清除掉
        final oldMaskId = [];
        for (var eachMaskedPiece in masks) {
          eachMaskedPiece.setMaskType(MaskType.none);
          oldMaskId.add(eachMaskedPiece.index);
        }
        masks.clear();

        // 设置新移动棋子的mask并加入masks
        _focusedPieceRef!.setMaskType(MaskType.moved);
        validClickedPieceRef.setMaskType(MaskType.moved);
        masks.add(_focusedPieceRef!);
        masks.add(validClickedPieceRef);

        // TODO: 生成刚刚走的棋子的招法，测试箭头
        final newMove = ChessMove(
          srcRow: _focusedPieceRef!.row,
          srcCol: _focusedPieceRef!.col,
          dstRow: validClickedPieceRef.row,
          dstCol: validClickedPieceRef.col,
          player: _player,
        );
        if (_player == Player.red) {
          _arrowMoves[0] = newMove;
        } else if (_player == Player.black) {
          _arrowMoves[1] = newMove;
        }
        // 必要更新（注意顺序）
        update([
          ...oldMaskId,
          _focusedPieceRef!.index,
          validClickedPieceRef.index,
        ]);
        _switchPlayer();
        await _updateBackData(); //更新后台数据
        _focusedPieceRef = null;
      }
    } else if (validClickedPieceRef.player() == _player) {
      validClickedPieceRef.setMaskType(MaskType.focused);
      _focusedPieceRef = validClickedPieceRef;
      update([_focusedPieceRef!.index]);
    }
  }

  _updateBackData() async {
    await _updateBoardData();
    await _updatePlayerData();
  }

  _updateBoardData() async {
    for (var piece in pieces) {
      await api.updateBoardData(
          row: piece.row, col: piece.col, pieceIndex: piece.pieceIndex());
    }
  }

  _updatePlayerData() async {
    switch (_player) {
      case Player.none:
        throw '更新后台玩家时发现None';
      case Player.red:
        await api.updatePlayerData(player: 'r');
        break;
      case Player.black:
        await api.updatePlayerData(player: 'b');
        break;
    }
  }

  Future<bool> isMoveOrEatable(Piece srcPiece, Piece dstPiece) async {
    if (_player == Player.none) {
      throw '错误：玩家不该是none';
    }
    if (srcPiece.player() != _player) {
      throw '错误：带检查的起始位置棋子非当前玩家';
    }
    if (dstPiece.player() == _player) {
      throw '错误：带检查的目标位置棋子是当前玩家';
    }

    return await api.isLegalMove(
        srcRow: srcPiece.row,
        srcCol: srcPiece.col,
        dstRow: dstPiece.row,
        dstCol: dstPiece.col);
  }

  // 若鼠标所选位置没有（空）棋子，则返回null
  List<int?> getNearestChessPos(Offset localPosition) {
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

  Piece? getChessPosFromOffset(Offset localPosition) {
    final nearestPos = getNearestChessPos(localPosition);

    var row = nearestPos[0];
    var col = nearestPos[1];
    if (row != null && col != null) {
      // 从_pieces中返回该位置的piece引用
      for (var piece in pieces) {
        if (piece.row == row && piece.col == col) {
          return piece;
        }
      }
    }
    return null;
  }
}
