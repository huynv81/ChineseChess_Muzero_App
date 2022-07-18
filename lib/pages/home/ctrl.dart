/*
 * @Author       : 老董
 * @Date         : 2022-04-29 10:49:11
 * @LastEditors  : 老董
 * @LastEditTime : 2022-07-15 17:25:34
 * @Description  : 用以控制HomeView的control组件
 */

import 'dart:async';
import 'dart:ffi';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/global.dart';
import '../../common/widgets/toast_message.dart';
import '../../ffi.dart';

class HomeController extends GetxController {
  final _dockActivate = false.obs;

  //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ucci engine stream↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  // http://cjycode.com/flutter_rust_bridge/feature/stream.html
  var ucciEngineBinder = "".obs;
  Stream<String>? ucciEngineStream;
  late final Worker worker;
  bool? _isFeedbackCorrect;
  //↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ucci engine stream↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

  //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓红黑方是否被电脑托管↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  final _isRedHosted = false.obs;
  get isRedHosted => _isRedHosted;
  set isRedHosted(value) => _isRedHosted.value = value;

  final _isBlackHosted = false.obs;
  get isBlackHosted => _isBlackHosted;
  set isBlackHosted(value) => _isBlackHosted.value = value;
  //↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑红黑方是否被电脑托管↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

  get dockActivate => _dockActivate.value;
  set dockActivate(value) => _dockActivate.value = value;

  HomeController() {
    for (var i = 0; i < boardRowCount * boardColCount; i++) {
      pieces.add(Piece(SidePieceType.none, i));
    }
    worker = ever(
      ucciEngineBinder,
      (value) {
        onReceiveUcciEngineMessage(value);
      },
    );
  }
// TODO：为何这个会被延迟接收？
  void onReceiveUcciEngineMessage(Object? value) {
    final engineFeedback = value.toString();
    final engineFeedbackLow = engineFeedback.toLowerCase();
    if (engineFeedbackLow == "hookok") {
    // if (engineFeedbackLow == "ucciok" || engineFeedback == "uciok") {
      _isFeedbackCorrect = true;
    }
    addLog(value.toString());
  }

  var gameStarted = false;
  final _logs = <DataRow>[].obs;

  final masks = <Piece>[]; //添加了mask的piece引用列表

  get logs => _logs;
  set logs(value) => _logs.value = value;

  //该list中是当前需要被展示的所有棋子信息
  final pieces = <Piece>[];

  // 需要绘制箭头的棋步
  final arrowMoves = <ChessMove>[];

  // set pieces(value) => _pieces.value = value;
  Piece? _focusedPieceRef; //被鼠标选中的棋子,指向_pieces中某piece元素的引用

  //
  var _player = Player.none;
  //
  final _animatedContainerHeight = toobarHeight.obs;
  get animatedContainerHeight => _animatedContainerHeight.value;
  set animatedContainerHeight(value) => _animatedContainerHeight.value = value;

  // real chess size
  var leftTopOffSet = const Offset(0.0, 0.0); //左上角棋子位置距离棋盘左上角的offset
  var pieceGap = 0.0; //相邻2个棋子中心位置的间距，x、y轴都一样
  var pieceSize = 0.0; //这个是调整过的棋子尺寸，宽高一致
  final _panelWidth = 0.0.obs; //这个是调整过的浮动工具栏宽度
  get panelWidth => _panelWidth.value;
  set panelWidth(value) => _panelWidth.value = value;

  final _borderRadius = 0.0.obs; //这个是调整过的浮动工具栏的圆角半径
  get borderRadius => _borderRadius.value;
  set borderRadius(value) => _borderRadius.value = value;

  Future<void> onToolButtonPressed(String logContent) async {
    addLog(logContent);
    final indexes = <int>[];

    switch (logContent) {
      case newChessGameLog:
        var correctRow = 0;
        var correctCol = 0;
        final origBoardArray = await ruleApi.getOrigBoard();
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
        masks.clear();
        arrowMoves.clear();

        // 后台数据更新
        await _updateBackData();
        //
        gameStarted = true;
        update(indexes);
        break;

      default: //测试用
        // String enginePath = Directory.current.path + '/assets/engines/$engine';
        // final engine = "eleeye.exe";
        // final result = await ruleApi.launchUcciEngine(enginePath: enginePath);
        // var r = await ruleApi.testGetOutput();
        // var r = await ruleApi.test2(s: "test");
        // await ucciApi.test(x: 5);
        // await ruleApi.testConflict1(s: "hi");

        await ruleApi.testLog1(log: "你好1");
        await ucciApi.writeToProcess(command: "ucci");
    }
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

  // 整个窗口任意位置点击均会触发此函数
  Future<void> onWindowClicked(Offset localPosition) async {
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

        // 设置新移动棋子的mask并加入masks
        _focusedPieceRef!.setMaskType(MaskType.moved);
        validClickedPieceRef.setMaskType(MaskType.moved);
        masks.clear();
        masks.add(_focusedPieceRef!);
        masks.add(validClickedPieceRef);

        // // TODO: 生成刚刚走的棋子的招法，测试箭头
        // arrowMoves.clear();
        // final newMove = ChessMove(
        //   srcRow: _focusedPieceRef!.row,
        //   srcCol: _focusedPieceRef!.col,
        //   dstRow: validClickedPieceRef.row,
        //   dstCol: validClickedPieceRef.col,
        //   player: _player,
        // );
        // arrowMoves.add(newMove);

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
      await ruleApi.updateBoardData(
          row: piece.row, col: piece.col, pieceIndex: piece.pieceIndex());
    }
  }

  _updatePlayerData() async {
    switch (_player) {
      case Player.none:
        throw '更新后台玩家时发现None';
      case Player.red:
        await ruleApi.updatePlayerData(player: 'r');
        break;
      case Player.black:
        await ruleApi.updatePlayerData(player: 'b');
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

    return await ruleApi.isLegalMove(
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

  Future<void> initAndBindUcciEngine(String path) async {
    ucciEngineStream = ucciApi.subscribeUcciEngine(enginePath: path);
    ucciEngineBinder.bindStream(ucciEngineStream!);

    final s = Stopwatch();
    s.start();
    const waitMSec = 5000;

    await Future.doWhile(() async {
      if (s.elapsedMilliseconds >= waitMSec) {
        return false; //停止循环
      }
      if (_isFeedbackCorrect != null) {
        return false; //停止循环
      }
      return true; //继续循环
    });

    // // await waitEngineCallBack();
  }

  // refer:https://stackoverflow.com/questions/69910901/add-wait-time-in-dart
//   Future<Bool> waitEngineCallBack({int waitMSec = 5000}) async {
//     Future.delayed(const Duration(seconds: 1, milliseconds: 600), () {
// // Here you can write your code
//     });
//     // final s = Stopwatch();
//     // s.start();
//     // while (s.elapsedMilliseconds < waitMSec) {
//     //   if (_isFeedbackCorrect != null) {
//     //     return _isFeedbackCorrect!;
//     //   }
//     // }
//     // return false;
//   }

  Future<bool> sendCommandToUcciEngine(String command,
      {int waitMSec = 5000}) async {
    await ucciApi.writeToProcess(command: command);

    // ignore: prefer_function_declarations_over_variables
    // final waitFunc = () async {
    //   while (s.elapsedMilliseconds < waitMSec) {
    //     if (_isFeedbackCorrect != null) {
    //       return _isFeedbackCorrect!;
    //     }
    //   }
    //   return false;
    // };

    // // recover
    // _isFeedbackCorrect = null;

    // //
    // return await waitFunc();
    return true;
  }

  Future<void> onAddNewEngineClicked() async {
    //pick engine
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['exe'],
    );
    if (result == null) {
      debugPrint("文件读取错误");
      return;
    }

    // launch engine process
    await initAndBindUcciEngine(result.files.single.path!);
    if (_isFeedbackCorrect == null || _isFeedbackCorrect == false) {
      debugPrint("引擎加载失败");
      return;
    }

    // 用“ucci”、”uci“指令测试引擎是否收发正常
    // await ucciApi.writeToProcess(command: "ucci");
    if (!await sendCommandToUcciEngine("ucci")) {
      if (!await sendCommandToUcciEngine("uci")) {
        debugPrint("引擎反馈失败");
        return;
      }
    }
    debugPrint("引擎加载/试运行成功");
  }
}
