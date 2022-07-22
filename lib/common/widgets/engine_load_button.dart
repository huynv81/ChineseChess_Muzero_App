import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

import '../../pages/home/lib.dart';
import '../global.dart';

class EngineLoadButton extends GetView<HomeController> {
  // MyButton({required this.player, required this.pullDownUi, Key? key})
  double _distance = 0.0;
  double _blur = 0.0;
  bool _isInSet = false;
  final double _containerSize = 104;
  late final double _iconSize;
  late final IconData _icon;

  EngineLoadButton(
      {required IconData iconData, required double iconSize, Key? key})
      : _iconSize = iconSize,
        _icon = iconData,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        controller.buttonState = NeumorphicButtonState.deepPressed;
      },
      onTapUp: (_) async {
        controller.isEngineLoaded
            ? await controller.onUnLoadEngine()
            : await controller.onLoadEngine();
        controller.isEngineLoaded
            ? controller.buttonState = NeumorphicButtonState.middlePressed
            : controller.buttonState = NeumorphicButtonState.noPressed;
      },
      child: Obx(
        () {
          switch (controller.buttonState) {
            case NeumorphicButtonState.deepPressed:
              _distance = 17;
              _blur = 3.0;
              _isInSet = true;
              break;
            case NeumorphicButtonState.middlePressed:
              _distance = 10.5;
              _blur = 3.0;
              _isInSet = true;
              break;
            case NeumorphicButtonState.noPressed:
              _distance = 11.0;
              _blur = 6.0;
              _isInSet = false;
              break;
            default:
              throw "NeumorphicButton未知buttonState";
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: _containerSize,
            height: _containerSize,
            decoration: BoxDecoration(
              color: const Color(0xff292d32),
              borderRadius: BorderRadius.circular(27),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff090d12),
                  Color(0xff494d52),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff494d52),
                  offset: Offset(-_distance * 0.5, -_distance * 0.5),
                  blurRadius: _blur,
                  spreadRadius: 0.0,
                  inset: _isInSet,
                ),
                BoxShadow(
                  color: const Color(0xff090d12),
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
              color: Colors.amber,
            ),
          );
        },
      ),
    );
  }
}
