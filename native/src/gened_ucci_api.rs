#![allow(
    non_camel_case_types,
    unused,
    clippy::redundant_closure,
    clippy::useless_conversion,
    clippy::unit_arg,
    clippy::double_parens,
    non_snake_case
)]
// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`.

use crate::ucci_api::*;
use flutter_rust_bridge::*;

// Section: imports

use crate::util_api::Player;

// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_subscribe_ucci_engine(
    port_: i64,
    player: i32,
    engine_path: *mut wire_uint_8_list,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "subscribe_ucci_engine",
            port: Some(port_),
            mode: FfiCallMode::Stream,
        },
        move || {
            let api_player = player.wire2api();
            let api_engine_path = engine_path.wire2api();
            move |task_callback| {
                subscribe_ucci_engine(api_player, api_engine_path, task_callback.stream_sink())
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_write_to_process(
    port_: i64,
    command: *mut wire_uint_8_list,
    msec: u32,
    player: i32,
    check_str_option: *mut wire_uint_8_list,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "write_to_process",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_command = command.wire2api();
            let api_msec = msec.wire2api();
            let api_player = player.wire2api();
            let api_check_str_option = check_str_option.wire2api();
            move |task_callback| {
                Ok(write_to_process(
                    api_command,
                    api_msec,
                    api_player,
                    api_check_str_option,
                ))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_is_process_loaded(port_: i64, msec: u32, player: i32) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "is_process_loaded",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_msec = msec.wire2api();
            let api_player = player.wire2api();
            move |task_callback| Ok(is_process_loaded(api_msec, api_player))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_is_process_unloaded(port_: i64, msec: u32, player: i32) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "is_process_unloaded",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_msec = msec.wire2api();
            let api_player = player.wire2api();
            move |task_callback| Ok(is_process_unloaded(api_msec, api_player))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_get_engine_name(port_: i64, player: i32) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_engine_name",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_player = player.wire2api();
            move |task_callback| Ok(get_engine_name(api_player))
        },
    )
}

// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: wrapper structs

// Section: static checks

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

pub trait Wire2Api<T> {
    fn wire2api(self) -> T;
}

impl<T, S> Wire2Api<Option<T>> for *mut S
where
    *mut S: Wire2Api<T>,
{
    fn wire2api(self) -> Option<T> {
        if self.is_null() {
            None
        } else {
            Some(self.wire2api())
        }
    }
}

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}

impl Wire2Api<i32> for i32 {
    fn wire2api(self) -> i32 {
        self
    }
}

impl Wire2Api<Player> for i32 {
    fn wire2api(self) -> Player {
        match self {
            0 => Player::Red,
            1 => Player::Black,
            _ => unreachable!("Invalid variant for Player: {}", self),
        }
    }
}

impl Wire2Api<u32> for u32 {
    fn wire2api(self) -> u32 {
        self
    }
}

impl Wire2Api<u8> for u8 {
    fn wire2api(self) -> u8 {
        self
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

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

// Section: impl IntoDart

// Section: executor

support::lazy_static! {
    pub static ref FLUTTER_RUST_BRIDGE_HANDLER: support::DefaultHandler = Default::default();
}
