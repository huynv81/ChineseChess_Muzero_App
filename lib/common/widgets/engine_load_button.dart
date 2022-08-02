/*
 * @Author       : 老董
 * @Date         : 2022-07-21 09:49:11
 * @LastEditors  : 老董
 * @LastEditTime : 2022-08-02 11:27:46
 * @Description  : player panel中那个“电脑图标”的按钮，用以加载引擎
 */
import 'package:chinese_chess_alpha_zero/gened_ucci_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

import '../../pages/home/lib.dart';
import '../global.dart';
import 'ios_menu_widget.dart';
import 'toast/toast_message.dart';

class EngineLoadButton extends GetView<HomeController> {
  // MyButton({required this.player, required this.pullDownUi, Key? key})
  double _distance = 0.0;
  double _blur = 0.0;
  bool _isInSet = false;
  late final double _containerSize;
  late final double _radius;
  late final double _iconSize;
  late final IconData _icon;
  double _containerIconRatio = 104 / 75;
  double _radiusContainerRatio = 27 / 104;
  double _deepPressDistanceContianerRatio = 17 / 104;
  double _middlePressDistanceContianerRatio = 10.5 / 104;
  double _noPressDistanceContianerRatio = 11 / 104;
  late final Color _iconColor;
  Player player;
  final _buttonState = NeumorphicButtonState.noPressed.obs;

  EngineLoadButton(
      {required this.player,
      required IconData iconData,
      required double iconSize,
      Key? key})
      : _iconSize = iconSize,
        _icon = iconData,
        super(key: key) {
    _containerSize = _containerIconRatio * _iconSize;
    _radius = _radiusContainerRatio * _containerSize;

    switch (player) {
      case Player.Red:
        _iconColor = Colors.red;
        break;
      case Player.Black:
        _iconColor = Colors.black;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _buttonState.value = NeumorphicButtonState.deepPressed;
      },
      onTapUp: (_) async {
        await controller.onEngineButtonPressed(context, player);
        controller.getEngineLoaded(player)
            ? _buttonState.value = NeumorphicButtonState.middlePressed
            : _buttonState.value = NeumorphicButtonState.noPressed;
      },
      child: Obx(
        () {
          switch (_buttonState.value) {
            case NeumorphicButtonState.deepPressed:
              _distance = _deepPressDistanceContianerRatio * _containerSize;
              _blur = 3.0;
              _isInSet = true;
              break;
            case NeumorphicButtonState.middlePressed:
              _distance = _middlePressDistanceContianerRatio * _containerSize;
              _blur = 3.0;
              _isInSet = true;
              break;
            case NeumorphicButtonState.noPressed:
              _distance = _noPressDistanceContianerRatio * _containerSize;
              _blur = 6.0;
              _isInSet = false;
              break;
            default:
              throw "NeumorphicButton未知buttonState";
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            width: _containerSize,
            height: _containerSize,
            decoration: BoxDecoration(
              // color: const Color(0xff292d32),
              // color: Color.fromARGB(255, 4, 239, 118),
              borderRadius: BorderRadius.circular(_radius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // container的底色
                colors: [
                  // Color(0xff090d12),
                  // Color(0xff494d52),
                  Colors.white,
                  Colors.white70,
                ],
              ),
              boxShadow: [
                // 左上角阴影
                BoxShadow(
                  color: const Color(0xff494d52),
                  // color: Color.fromARGB(255, 3, 102, 255),
                  offset: Offset(-_distance * 0.3, -_distance * 0.15),
                  blurRadius: _blur,
                  spreadRadius: 0.0,
                  inset: _isInSet,
                ),
                // 左下角阴影
                BoxShadow(
                  color: const Color(0xff090d12),
                  // color: Color.fromARGB(255, 6, 36, 72),
                  offset: Offset(_distance, _distance),
                  blurRadius: _blur,
                  spreadRadius: 0.0,
                  inset: _isInSet,
                ),
              ],
            ),
            child: Icon(
              _icon,
              size: _iconSize,
              color: _iconColor,
            ),
          );
        },
      ),
    );
  }
}
