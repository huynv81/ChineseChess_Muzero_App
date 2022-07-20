import 'package:chinese_chess_alpha_zero/common/global.dart';
import 'package:flutter/material.dart';

import '../../lib.dart';
import 'digital_font/digital_colon.dart';
import 'digital_font/digital_number.dart';
import 'package:pausable_timer/pausable_timer.dart';

class NeuDigitalClock extends GetView<HomeController> {
  double outerRoundRadius;
  late double innerRoundRadius;
  final _innerOuterRadiusRatio = 10 / 15;

  int _elapsedMSecs = 0;
  late final PausableTimer _timer;
  late final DigitTimeController _timeController;
  late final Worker worker;

  NeuDigitalClock(Player player, this.outerRoundRadius, {Key? key})
      : super(key: key) {
    //
    switch (player) {
      case Player.red:
        _timeController = controller.redTimeController;
        break;
      case Player.black:
        _timeController = controller.blackTimeController;
        break;
      default:
        throw "初始化电子表时出现未知的玩家";
    }
    // ui radius
    innerRoundRadius = _innerOuterRadiusRatio * outerRoundRadius;

    // Timer
    _timer = PausableTimer(
      const Duration(milliseconds: 1000),
      () {
        _elapsedMSecs += 1000;
        _timeController.setTimeElapsed(_elapsedMSecs);
        // debugPrint("time 111");

        _timer
          ..reset()
          ..start();
      },
    );

    //work
    worker = ever(
      _timeController.timerState,
      (value) {
        switch (value) {
          case TimerControlType.start:
            if (!_timer.isActive) {
              startTimer();
            }
            break;
          case TimerControlType.stop:
            if (_timer.isActive || _timer.isPaused) {
              stopTimer();
            }
            break;
          case TimerControlType.pause:
            if (_timer.isActive) {
              pauseTimer();
            }
            break;
        }
      },
    );
  }

  startTimer() {
    _timer.start();
  }

  stopTimer() {
    _timer.pause();
    _timer.reset();
    _elapsedMSecs = 0;
    _timeController.setTimeElapsed(_elapsedMSecs); //更新ui显示
  }

  pauseTimer() {
    _timer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      // Outer white container
      decoration: BoxDecoration(
        // color: Color.fromRGBO(217, 230, 243, 1),
        borderRadius: BorderRadius.circular(outerRoundRadius),
        // boxShadow: const [
        //   BoxShadow(
        //     blurRadius: 15,
        //     offset: Offset(-5, -5),
        //     color: Colors.white,
        //   ),
        //   BoxShadow(
        //     blurRadius: 15,
        //     offset: Offset(10.5, 10.5),
        //     color: Color.fromRGBO(214, 223, 230, 1),
        //   )
        // ],
      ),
      // Digital green background
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) => Container(
            height: constraints.maxHeight * 0.87,
            width: constraints.maxWidth * 0.95,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                Color.fromRGBO(203, 211, 196, 1),
                Color.fromRGBO(176, 188, 163, 1)
              ]),
              borderRadius: BorderRadius.circular(innerRoundRadius),
              border: Border.all(
                color: const Color.fromRGBO(168, 168, 168, 1),
                width: 2,
              ),
            ),
            child: Obx(
              () => DigitalClock(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                seconds: _timeController.inSeconds,
                minutes: _timeController.inMinutes,
                hours: _timeController.inHours,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DigitalClock extends StatelessWidget {
  const DigitalClock({
    required this.height,
    required this.width,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
  });

  final num height;
  final num width;
  final int hours;
  final int minutes;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    List<DigitalNumberWithBG> hourNumber = createNumberTime(hours);
    List<DigitalNumberWithBG> minuteNumber = createNumberTime(minutes);
    List<DigitalNumberWithBG> secondNumber = createNumberTime(seconds);
    return Center(
      child: SizedBox(
        // color: Colors.green, //数字的颜色
        height: height * 1.0, // 0.47,
        width: width * 0.6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...hourNumber,
            DigitalColon(height: height * 0.50, color: Colors.black87),
            ...minuteNumber,
            DigitalColon(height: height * 0.50, color: Colors.black87),
            ...secondNumber,
          ],
        ),
      ),
    );
  }

  List<DigitalNumberWithBG> createNumberTime(int numberTime) {
    final parsedNumberTime = numberTime % 60;
    final isNumberTimeTwoDigits = isNumberTwoDigits(parsedNumberTime);
    final firstNumber = firstDigit(parsedNumberTime);
    final tenDigit = isNumberTimeTwoDigits ? firstNumber : 0;
    final digit = isNumberTimeTwoDigits
        ? int.parse(parsedNumberTime.toString()[1])
        : firstNumber;

    return [
      DigitalNumberWithBG(
        height: height * 0.35,
        value: tenDigit,
      ),
      DigitalNumberWithBG(
        height: height * 0.35,
        value: digit,
      ),
    ];
  }
}

class DigitalNumberWithBG extends StatelessWidget {
  const DigitalNumberWithBG({
    this.value = 0,
    // required this.padLeft,
    required this.height,
    // required this.color,
    this.backgroundValue = 8,
  });

  final int value;
  final int backgroundValue;
  // final int padLeft;
  final double height;
  // final Color color;

  final numberScaleRatio = 1.4;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        //Foreground(数字本身的颜色)
        DigitalNumber(
          value: value,
          color: Colors.black,
          height: height * numberScaleRatio,
        ),

        // Background
        DigitalNumber(
          value: backgroundValue,
          color: Colors.black12,
          height: height * numberScaleRatio,
        ),
      ],
    );
  }
}

bool isNumberTwoDigits(int number) {
  return number.toString().length == 2;
}

int firstDigit(int number) {
  return int.parse(number.toString()[0]);
}
