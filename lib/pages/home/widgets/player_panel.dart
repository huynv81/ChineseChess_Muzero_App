/*
 * @Author       : 老董
 * @Date         : 2022-04-30 11:10:14
 * @LastEditors  : 老董
 * @LastEditTime : 2022-07-19 21:53:56
 * @Description  : 包含红黑方剩余时间、引擎名字的状态条（红黑方各需要一个）
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/global.dart';
import '../lib.dart';
import 'engine_pull_down_button.dart';
import 'timer/neu_digital_clock.dart';

class PlayerPanel extends GetView<HomeController> {
  final Player player;
  final EnginePulldownButton pullDownUi;
  late final RxBool _isHosted;

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
  }

  @override
  Widget build(BuildContext context) {
    const padSize = 5.0;
    final barHeight = padSize * 2 + controller.pieceSize;
    final iconSize = barHeight * 0.4;
    const roundRadius = 20.0;

    return Obx(
      () => Card(
        shadowColor: getPlayerColor(),
        elevation: 15,
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
          padding: const EdgeInsets.only(
              top: padSize, right: padSize, bottom: padSize),
          // padding: const EdgeInsets.all(padSize),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: _isHosted.value
                                  ? BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blueGrey, width: 1),
                                      color: Colors.transparent,
                                      shape: BoxShape.rectangle,
                                    )
                                  : null,
                              child: IconButton(
                                onPressed: () {
                                  _isHosted.value = !_isHosted.value;
                                },
                                icon: Icon(
                                  Icons.computer_sharp,
                                  color: getPlayerColor(),
                                ),
                              ),
                            ),
                            //
                            // 分割
                            SizedBox(width: iconSize / 2),
                            //
                            const Flexible(
                              child: Text(
                                "被fskdfsdjsdfdls引擎名字",
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Container(
                        child: NeuDigitalClock(player, roundRadius),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getPlayerColor() {
    return player == Player.red ? Colors.red : Colors.black;
  }
}
