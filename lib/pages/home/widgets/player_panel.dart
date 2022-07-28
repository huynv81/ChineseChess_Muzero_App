/*
 * @Author       : 老董
 * @Date         : 2022-04-30 11:10:14
 * @LastEditors  : 老董
 * @LastEditTime : 2022-07-28 10:38:35
 * @Description  : 包含红黑方剩余时间、引擎名字的状态条（红黑方各需要一个）
 */

import 'package:chinese_chess_alpha_zero/common/widgets/engine_load_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/global.dart';
import '../lib.dart';
import 'engine_pull_down_button.dart';
import 'timer/player_digital_clock.dart';

class PlayerPanel extends GetView<HomeController> {
  final Player player;
  final EnginePulldownButton pullDownUi;
  late final RxBool _isHosted;
  final _fontRatio = 16 / 58; //font: pieceSize

  PlayerPanel({required this.player, required this.pullDownUi, Key? key})
      : super(key: key) {
    switch (player) {
      case Player.red:
        _isHosted = controller.isRedHosted;
        break;
      case Player.black:
        _isHosted = controller.isBlackHosted;
        break;
      default:
        throw '创建红黑方时间组件时错误：player类型为none';
    }

    // _iconRatio = /controller.;
  }

  @override
  Widget build(BuildContext context) {
    const padSize = 5.0;
    final barHeight = padSize * 2 + controller.pieceSize;
    final iconSize = controller.pieceSize * 0.4 - padSize;
    const roundRadius = 20.0;

    return Card(
      shadowColor: getPlayerColor(),
      elevation: 20,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(roundRadius)),
      clipBehavior: Clip.antiAlias,
      // margin: EdgeInsetsGeometry.infinity,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [getPlayerColor(), Colors.blueGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        height: barHeight,
        padding: const EdgeInsets.only(top: padSize, bottom: padSize),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                child: SvgPicture.asset(
                  getPlayerIconImagePath(player),
                  width: controller.pieceSize,
                  height: controller.pieceSize,
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            // child: Icon(size: iconSize, Icons.computer),
                            child: EngineLoadButton(
                              player:player,
                              iconData: Icons.computer,
                              iconSize: iconSize,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            padding: const EdgeInsets.only(left: 5.0),
                            alignment: Alignment.topCenter,
                            child: Text(
                              '人类',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: _fontRatio * controller.pieceSize),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: PlayerDigitalClock(player, roundRadius),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getPlayerColor() {
    return player == Player.red ? Colors.red : Colors.black;
  }
}
