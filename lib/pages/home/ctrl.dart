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

class HomeController extends GetxController {
  final _logs = <DataRow>[].obs;
  get logs => _logs;
  
  set logs(value) => _logs.value = value;
  //
  final _animatedContainerHeight = toobarHeight.obs;
  get animatedContainerHeight => _animatedContainerHeight.value;
  set animatedContainerHeight(value) => _animatedContainerHeight.value = value;

  onTest() {
    Get.snackbar("test", "");
  }

  void onToolButtonPressed(String content) {
    _logs.add(
      DataRow(
        cells: [
          DataCell(Text(getCurrentTimeString())),
          DataCell(Text(content)),
        ],
      ),
    );
  }
}
