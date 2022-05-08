// /*
//  * @Author       : 老董
//  * @Date         : 2022-04-30 11:10:14
//  * @LastEditors  : 老董
//  * @LastEditTime : 2022-05-05 16:50:45
//  * @Description  : windows风格的工具栏
//  */

// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';

// import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart' as material;
// // import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:window_manager/window_manager.dart';

// import '../pages/home_page/ctrl.dart';
// import 'dialog_widget.dart';
// import 'menu_widget.dart';

// class CommandBars extends StatefulWidget {
//   const CommandBars({Key? key}) : super(key: key);

//   @override
//   _CommandBarsState createState() => _CommandBarsState();
// }

// class _CommandBarsState extends State<CommandBars> {
//   // vertical version
//   // late final int _rotateQuarter;
//   // final bool vertical;
//   // CommandBars({Key? key, required this.vertical}) : super(key: key) {
//   // _rotateQuarter = vertical ? -1 : 0;
//   // }

// //
//   List<dynamic> getBasicToolBarItems() => <CommandBarItem>[
//         CommandBarBuilderItem(
//           builder: (context, mode, w) => Tooltip(
//             message: "新建一局",
//             child: w,
//           ),
//           wrappedItem: CommandBarButton(
//             icon: const Icon(material.Icons.add),
//             // label: const Text('新'),
//             onPressed: () {
//               // TODO：
//               Get.snackbar(
//                 "标题",
//                 "消息",
//               );
//             },
//             trailing: const Icon(material.Icons.add),
//           ),
//         ),
//         CommandBarBuilderItem(
//           builder: (context, mode, w) => Tooltip(
//             message: "电脑执红",
//             child: w,
//           ),
//           wrappedItem: CommandBarButton(
//             icon: Icon(material.Icons.computer, color: Colors.red),
//             onPressed: () {},
//           ),
//         ),
//         CommandBarBuilderItem(
//           builder: (context, mode, w) => Tooltip(
//             message: "电脑执黑",
//             child: w,
//           ),
//           wrappedItem: CommandBarButton(
//             icon: Icon(material.Icons.computer, color: Colors.blue),
//             onPressed: () {},
//           ),
//         ),
//         CommandBarBuilderItem(
//           builder: (context, mode, w) => Tooltip(
//             message: "连线到第三方平台",
//             child: w,
//           ),
//           wrappedItem: CommandBarButton(
//             icon: const Icon(material.Icons.link),
//             onPressed: () {
//               getIosPopUpMenu(context);
//             },
//           ),
//         ),
//         CommandBarBuilderItem(
//           builder: (context, mode, w) => Tooltip(
//             message: "训练内置AI引擎",
//             child: w,
//           ),
//           wrappedItem: CommandBarButton(
//             icon: const Text('AI'),
//             onPressed: () {},
//           ),
//         ),
//         CommandBarBuilderItem(
//           builder: (context, mode, w) => Tooltip(
//             message: "设置",
//             child: w,
//           ),
//           wrappedItem: CommandBarButton(
//             icon: const Icon(material.Icons.settings),
//             onPressed: () {},
//           ),
//         ),
//       ];

//   List<CommandBarItem> getWindowToolBarItems() => <CommandBarItem>[
//         // 最小化窗口按钮
//         CommandBarBuilderItem(
//           builder: (context, mode, w) => Tooltip(
//             message: "最小化窗口",
//             child: w,
//           ),
//           wrappedItem: CommandBarButton(
//             icon: const Icon(material.Icons.minimize),
//             onPressed: () {
//               windowManager.minimize();
//             },
//           ),
//         ),
//         // 关闭窗口按钮
//         CommandBarBuilderItem(
//           builder: (context, mode, w) => Tooltip(
//             message: "退出程序",
//             child: w,
//           ),
//           wrappedItem: CommandBarButton(
//             icon: const Icon(material.Icons.close),
//             onPressed: () {
//               showIosDialog(
//                 context,
//                 onYesPressed: () => exit(0),
//               );
//             },
//           ),
//         ),
//       ];

//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//       constraints: const BoxConstraints(maxWidth: 250),
//       child: Container(
//         // Add the line below
//         clipBehavior: Clip.antiAlias,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10.0),
//           // border: Border.all(color: Colors.green, width: 2.0)
//         ),

//         child: getCommandBarWidget(),
//       ),
//     );
//   }

//   Widget getCommandBarWidget() {
//     final cmdBar = CommandBar(
//       overflowBehavior: CommandBarOverflowBehavior.clip,
//       isCompact: true,
//       primaryItems: [
//         ...getBasicToolBarItems(),
//         const CommandBarSeparator(),
//         ...getWindowToolBarItems(),
//       ],
//     );
//     return cmdBar;
//   }
// }
