## 项目说明
  一款基于强化学习算法Muzero的中国象棋ui程序，取名《梦入零式》。
  因基于跨平台的flutter/dart（界面）+rust（算法后端）开发，所以理论上可用于任意平台，但由于测试平台在win10，且多数ucci引擎只有windows版本，所以目前适配最好的平台只有windows。

## 功能
  - 可加载基于ucci协议的中国象棋引擎
  - 可自定义连线方案，连线各象棋游戏平台进行自动下棋
  - 带有一款内置的基于muzero算法的中国象棋引擎
  - 可将三方的ucci引擎和内置引擎进行打擂比赛
  - 可将三方的ucci引擎辅助内置引擎进行训练

## todo
 - [] 绘制象棋界面--fluent ui  snack bar tabview  acrylic 鼠标侧边栏
 - [] 重启读取配置

## ui issue
可否内置divider\垂直按钮、tooltip\选中话框\下拉菜单会空？

## 编译说明
为了通过FFI衔接dart+rust，使用了[flutter_rust_bridge_template](https://github.com/Desdaemon/flutter_rust_bridge_template)模板。以下为该模板中的部分配置说明（just用以生成rust侧的接口代码，而flutter run则用以生成dart侧的接口代码及最终app）。

To begin, ensure that you have a working installation of the following items:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Rust language](https://rustup.rs/)
- Appropriate [Rust targets](https://rust-lang.github.io/rustup/cross-compilation.html) for cross-compiling to your device
- For Android targets:
    - Install [cargo-ndk](https://github.com/bbqsrc/cargo-ndk#installing)
    - Install Android NDK 22, then put its path in one of the `gradle.properties`, e.g.:

```
echo "ANDROID_NDK=.." >> ~/.gradle/gradle.properties
```

- Web is not supported yet.

Then go ahead and run `just` and `flutter run`! When you're ready, refer to our documentation
[here](https://fzyzcjy.github.io/flutter_rust_bridge/index.html)
to learn how to write and use binding code.

## 参考资料
