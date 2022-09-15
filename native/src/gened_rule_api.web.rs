use super::*;
// Section: wire functions

#[wasm_bindgen]
pub fn wire_test_log_1(port_: MessagePort, log: String) {
    wire_test_log_1_impl(port_, log)
}

#[wasm_bindgen]
pub fn wire_test_print_1(port_: MessagePort, log: String) {
    wire_test_print_1_impl(port_, log)
}

#[wasm_bindgen]
pub fn wire_is_legal_move(port_: MessagePort, src_row: u8, src_col: u8, dst_row: u8, dst_col: u8) {
    wire_is_legal_move_impl(port_, src_row, src_col, dst_row, dst_col)
}

#[wasm_bindgen]
pub fn wire_get_orig_board(port_: MessagePort) {
    wire_get_orig_board_impl(port_)
}

#[wasm_bindgen]
pub fn wire_update_board_data(port_: MessagePort, row: u8, col: u8, piece_index: u8) {
    wire_update_board_data_impl(port_, row, col, piece_index)
}

#[wasm_bindgen]
pub fn wire_update_player_data(port_: MessagePort, player: String) {
    wire_update_player_data_impl(port_, player)
}

// Section: allocate functions

// Section: impl Wire2Api

impl Wire2Api<String> for String {
    fn wire2api(self) -> String {
        self
    }
}

impl Wire2Api<Vec<u8>> for Box<[u8]> {
    fn wire2api(self) -> Vec<u8> {
        self.into_vec()
    }
}
// Section: impl Wire2Api for JsValue

impl Wire2Api<String> for JsValue {
    fn wire2api(self) -> String {
        self.as_string().expect("non-UTF-8 string, or not a string")
    }
}
impl Wire2Api<u8> for JsValue {
    fn wire2api(self) -> u8 {
        self.unchecked_into_f64() as _
    }
}
impl Wire2Api<Vec<u8>> for JsValue {
    fn wire2api(self) -> Vec<u8> {
        self.unchecked_into::<js_sys::Uint8Array>().to_vec().into()
    }
}
