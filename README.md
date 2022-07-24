## 项目说明
  一款基于强化学习算法Muzero的中国象棋ui程序，取名《梦入零式》。
  因基于跨平台的flutter/dart（界面）+rust（算法后端）开发，所以理论上可用于任意平台，但由于测试平台在win10，且多数ucci引擎只有windows版本，所以目前适配最好的平台只有windows。

## 软件截图
![image](https://github.com/dbsxdbsx/ChineseChess_Muzero_App/blob/main/img/%E5%8D%8A%E6%88%90%E5%93%81%E6%88%AA%E5%9B%BE.PNG)

## 功能
  - [x] 可加载基于ucci协议的中国象棋引擎
  - []  可自定义连线方案，连线各象棋游戏平台进行自动下棋
  - []  带有一款内置的基于muzero算法的中国象棋引擎
  - []  可将三方的ucci引擎和内置引擎进行打擂比赛
  - []  可将三方的ucci引擎辅助内置引擎进行训练

## todo
- 为何引擎加载了却没有反馈，是否应该用thread 代替 Tokio来降低内存占用？
- 展开时并放大缩小时，1.距离边界的width会被重置到最边上，且border不固定。须修复；
 - [] 拓展时随便点击哪里都可以拖动（还有个yOffset问题）、 缩小dock时鼠标聚焦后可挪出一点点、
 - [] 浮动工具栏须在窗口放大缩小时 等比率调整位置和大小、透明acrylic
 - [] 绘制象棋界面--fluent ui  snack bar tabview  acrylic 鼠标侧边栏
 - [] 重启读取配置
 - [] 启动阿童木ucci引擎

## ui issue
可否内置divider\垂直按钮、tooltip\选中话框\下拉菜单会空？

## 编译说明
本程序仅在windows测试，使用了[frb](https://github.com/fzyzcjy/flutter_rust_bridge)作为核心框架来绑定flutter和rust。
1.安装[Flutter SDK](https://docs.flutter.dev/get-started/install)
2.安装[Rust SDK](https://rustup.rs/)
3.安装cmake和flutter+rust桌面app所需要的库[corrison](http://cjycode.com/flutter_rust_bridge/template/setup_desktop.html)，然后进入windows/rust.cmake，将corrison的获取方式改为`find_package(Corrosion REQUIRED)`并注释掉下方通过github获取的方式。
4.安装llvm和安装编译所需其他工具链：
```
winget install -e --id LLVM.LLVM
cargo install flutter_rust_bridge_codegen just
dart pub global activate ffigen
```
5.更新必要的flutter包：
```dart
flutter pub add -d build_runner
flutter pub add -d freezed
flutter pub add freezed_annotation
```
[关于freeze的介绍](https://github.com/rrousselGit/freezed)
6.justtfile中`gen`流程最后添加这句话:
```shell
 gen:
     ..
     flutter pub run build_runner build --delete-conflicting-outputs
```
并运行`just`生成rust绑定代码（只有rust代码有变动才需要）
7.flutter run （将生成flutter侧的绑定代码，并最总生成app）

([官方参考](http://cjycode.com/flutter_rust_bridge/template/generate.html)、[flutter_rust_bridge官方模板](https://github.com/Desdaemon/flutter_rust_bridge_template)）

## 常见问题
### **运行`just clean`出现错误**
```
flutter clean
error: Recipe `clean` could not be run because just could not find the shell: program not found
```
在windows平台编译时，请使用git bash，不要用power shell。
### **如何清除并重新生成？**
`just clean && flutter pub get && just && flutter run`
若仅更改了dart代码，则直接`flutter run`
若还更改了rust代码，则`just && flutter run`
### **是否支持中文文件夹？**
经测试，不支持。否则编译app时会发生各种奇怪的错误（文件名中最好也不要有“中划线”）。

### **多rust模块生成？**
https://github.com/fzyzcjy/flutter_rust_bridge/pull/481
### **如何隐藏运行时加载的ucci引擎窗口？**
将`windows/runner/main.cpp`中的
```c++
 if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }
```
替换为
```c++
if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
  CreateAndAttachConsole();
} else {
  AllocConsole();
  ShowWindow(GetConsoleWindow(), SW_HIDE);
}
```
参考：https://stackoverflow.com/questions/67082272/dart-how-to-hide-cmd-when-using-process-run