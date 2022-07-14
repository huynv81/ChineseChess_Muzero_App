/*
 * @Author       : 老董
 * @Date         : 2022-04-30 11:10:14
 * @LastEditors  : 老董
 * @LastEditTime : 2022-07-14 19:53:31
 * @Description  : 包含红黑方剩余时间、引擎名字的状态条（红黑方各需要一个）
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/global.dart';
import '../ctrl.dart';
import 'engine_pull_down_button.dart';

class PlayerEngineTimeBar extends GetView<HomeController> {
  final Player player;
  final EnginePulldownButton pullDownUi;
  late final RxBool _isHosted;

  PlayerEngineTimeBar(
      {required this.player, required this.pullDownUi, Key? key})
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
    return Obx(
      () => Card(
        // color: Colors.transparent,
        // margin: EdgeInsetsGeometry.infinity,
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(0.0),
              decoration: _isHosted.value
                  ? BoxDecoration(
                      border: Border.all(color: Colors.blueGrey, width: 1),
                      color: Colors.transparent,
                      shape: BoxShape.rectangle,
                    )
                  : null,
              child: IconButton(
                icon: player == Player.red
                    ? Image.asset("assets/icon/rk.png")
                    : Image.asset("assets/icon/bk.png"),
                onPressed: () {
                  _isHosted.value = !_isHosted.value;
                },
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [pullDownUi, const Text("已加载的引擎名字")],
                ),
                const Text("电子钟")
              ],
            ),
          ],
        ),
      ),
    );
  }
}
