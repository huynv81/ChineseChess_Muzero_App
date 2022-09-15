use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_test_log_1(port_: i64, log: *mut wire_uint_8_list) {
    wire_test_log_1_impl(port_, log)
}

#[no_mangle]
pub extern "C" fn wire_test_print_1(port_: i64, log: *mut wire_uint_8_list) {
    wire_test_print_1_impl(port_, log)
}

#[no_mangle]
pub extern "C" fn wire_is_legal_move(
    port_: i64,
    src_row: u8,
    src_col: u8,
    dst_row: u8,
    dst_col: u8,
) {
    wire_is_legal_move_impl(port_, src_row, src_col, dst_row, dst_col)
}

#[no_mangle]
pub extern "C" fn wire_get_orig_board(port_: i64) {
    wire_get_orig_board_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_update_board_data(port_: i64, row: u8, col: u8, piece_index: u8) {
    wire_update_board_data_impl(port_, row, col, piece_index)
}

#[no_mangle]
pub extern "C" fn wire_update_player_data(port_: i64, player: *mut wire_uint_8_list) {
    wire_update_player_data_impl(port_, player)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
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

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturnStruct(val: support::WireSyncReturnStruct) {
    unsafe {
        let _ = support::vec_from_leak_ptr(val.ptr, val.len);
    }
}
