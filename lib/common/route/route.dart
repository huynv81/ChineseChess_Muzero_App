/*
 * @Author       : 老董
 * @Date         : 2022-04-29 10:27:31
 * @LastEditors  : 老董
 * @LastEditTime : 2022-05-08 16:24:43
 * @Description  : 基于get的路由
 */

import 'package:get/get.dart';

// import '../../pages/home/lib.dart';
import '../../pages/home/lib.dart';
import '../../pages/train/lib.dart';

abstract class Routes {
  static const home = '/home';
  static const train = '/train';
}

abstract class AppPages {
  static final pages = [
    // 主页
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(
        () {
          // Get.put<Service>(() => Api());
          Get.lazyPut<HomeController>(() => HomeController());
        },
      ),
    ),
    // 训练页
    GetPage(
      name: Routes.train,
      page: () => const TrainView(),
      binding: BindingsBuilder(
        () {
          // Get.put<Service>(() => Api());
          Get.lazyPut<TrainController>(() => TrainController());
        },
      ),
    ),
  ];
}
