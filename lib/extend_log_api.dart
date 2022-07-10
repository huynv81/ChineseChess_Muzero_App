import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';

import 'gened_log_api.dart';
import 'dart:ffi' as ffi;

class LogApiImplExtend extends LogApiImpl with FlutterRustBridgeSetupMixin {
  factory LogApiImplExtend(ffi.DynamicLibrary dylib) =>
      LogApiImplExtend._raw(LogApiWire(dylib));

  LogApiImplExtend._raw(super.inner) : super.raw() {
    setupMixinConstructor();
  }

  @override
  Future<void> setup() async {
    await initLogger(hint: FlutterRustBridgeSetupMixin.kHintSetup);
  }
}
