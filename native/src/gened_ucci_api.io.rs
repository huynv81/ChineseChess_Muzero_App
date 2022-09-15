use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_subscribe_ucci_engine(
    port_: i64,
    player: i32,
    engine_path: *mut wire_uint_8_list,
) {
    wire_subscribe_ucci_engine_impl(port_, player, engine_path)
}

#[no_mangle]
pub extern "C" fn wire_write_to_process(
    port_: i64,
    command: *mut wire_uint_8_list,
    msec: u32,
    player: i32,
    check_str_option: *mut wire_uint_8_list,
) {
    wire_write_to_process_impl(port_, command, msec, player, check_str_option)
}

#[no_mangle]
pub extern "C" fn wire_is_process_loaded(port_: i64, msec: u32, player: i32) {
    wire_is_process_loaded_impl(port_, msec, player)
}

#[no_mangle]
pub extern "C" fn wire_is_process_unloaded(port_: i64, msec: u32, player: i32) {
    wire_is_process_unloaded_impl(port_, msec, player)
}

#[no_mangle]
pub extern "C" fn wire_get_engine_name(port_: i64, player: i32) {
    wire_get_engine_name_impl(port_, player)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_uint_8_list_1(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}
