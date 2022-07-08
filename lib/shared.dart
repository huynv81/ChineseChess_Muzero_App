class MyTest {}
// final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
//     _lookup = dynamicLibrary.lookup;

// //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓string↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
// ffi.Pointer<wire_uint_8_list> new_uint_8_list(
//   int len,
// ) {
//   return _new_uint_8_list(
//     len,
//   );
// }

// late final _new_uint_8_listPtr = _lookup<
//         ffi.NativeFunction<ffi.Pointer<wire_uint_8_list> Function(ffi.Int32)>>(
//     'new_uint_8_list');

// late final _new_uint_8_list = _new_uint_8_listPtr
//     .asFunction<ffi.Pointer<wire_uint_8_list> Function(int)>();
// //↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑string↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

// class wire_uint_8_list extends ffi.Struct {
//   external ffi.Pointer<ffi.Uint8> ptr;
// //
//   @ffi.Int32()
//   external int len;
// }
