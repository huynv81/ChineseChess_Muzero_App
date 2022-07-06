import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ctrl.dart';

class LogTable extends GetView<HomeController> {
  const LogTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text("时间")),
            DataColumn(label: Text("内容")),
          ],
          rows: controller.logs,
        ),
      ),
    );
  }
}
