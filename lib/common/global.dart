/*
 * @Author       : 老董
 * @Date         : 2022-04-29 22:27:48
 * @LastEditors  : 老董
 * @LastEditTime : 2022-05-07 16:09:06
 * @Description  : 全局属性
 */
import 'dart:ui';
import 'package:intl/intl.dart';

const backgroundStartColor = Color(0xffffd500);
const backgroundEndColor = Color(0xfff6a00c);

const toobarHeight = 40.0;
const hideToobarHeight = 20.0;
double boardWidth = 521;
double boardHeight = 577;

String getCurrentTimeString() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('kk:mm:ss').format(now);
  // String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
  return formattedDate;
}
