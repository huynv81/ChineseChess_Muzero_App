use std::process::Command;

use crate::chess::{get_piece_all_valid_moves, BOARD_ARRAY};

// This is the entry point of your Rust library.
// When adding new code to your project, note that only items used
// here will be transformed to their Dart equivalents.

// A plain enum without any fields. This is similar to Dart- or C-style enums.
// flutter_rust_bridge is capable of generating code for enums with fields
// (@freezed classes in Dart and tagged unions in C).
pub enum Platform {
    Unknown,
    Android,
    Ios,
    Windows,
    Unix,
    MacIntel,
    MacApple,
    Wasm,
}

// A function definition in Rust. Similar to Dart, the return type must always be named
// and is never inferred.
pub fn platform() -> Platform {
    // This is a macro, a special expression that expands into code. In Rust, all macros
    // end with an exclamation mark and can be invoked with all kinds of brackets (parentheses,
    // brackets and curly braces). However, certain conventions exist, for example the
    // vector macro is almost always invoked as vec![..].
    //
    // The cfg!() macro returns a boolean value based on the current compiler configuration.
    // When attached to expressions (#[cfg(..)] form), they show or hide the expression at compile time.
    // Here, however, they evaluate to runtime values, which may or may not be optimized out
    // by the compiler. A variety of configurations are demonstrated here which cover most of
    // the modern oeprating systems. Try running the Flutter application on different machines
    // and see if it matches your expected OS.
    //
    // Furthermore, in Rust, the last expression in a function is the return value and does
    // not have the trailing semicolon. This entire if-else chain forms a single expression.
    if cfg!(windows) {
        Platform::Windows
    } else if cfg!(target_os = "android") {
        Platform::Android
    } else if cfg!(target_os = "ios") {
        Platform::Ios
    } else if cfg!(target_arch = "aarch64-apple-darwin") {
        Platform::MacApple
    } else if cfg!(target_os = "macos") {
        Platform::MacIntel
    } else if cfg!(target_family = "wasm") {
        Platform::Wasm
    } else if cfg!(unix) {
        Platform::Unix
    } else {
        Platform::Unknown
    }
}

// The convention for Rust identifiers is the snake_case,
// and they are automatically converted to camelCase on the Dart side.
pub fn rust_release_mode() -> bool {
    cfg!(not(debug_assertions))
}

pub fn is_legal_move(src_row: u8, src_col: u8, dst_row: u8, dst_col: u8) -> bool {
    let src_pos = crate::chess::get_board_pos_from_row_col(src_row, src_col);
    let dst_pos = crate::chess::get_board_pos_from_row_col(dst_row, dst_col);
    // println!("起始行列是：行{src_row} 列{src_col}");
    // println!("目标行列是：行{dst_row} 列{dst_col}");
    // println!("起始pos是：{src_pos}");
    // println!("目标pos是：{dst_pos}");

    // get src piece|
    let board_array = BOARD_ARRAY.lock().unwrap();
    let unside_src_piece = crate::chess::get_unside_piece_by_pos(&board_array, src_pos);
    let move_str_to_check = crate::chess::get_english_move_str_from_pos(src_pos, dst_pos);
    println!("move str:{move_str_to_check}");
    // println!("棋子:{unside_src_piece:?}");

    // check all move of the piece
    let valid_moves = get_piece_all_valid_moves(&board_array, src_pos, unside_src_piece);
    println!("valid_moves:{valid_moves:?}");

    let contains = valid_moves.contains(&move_str_to_check);
    println!("back:{contains}");
    return contains;
}

pub fn get_orig_board() -> [u8; 256] {
    crate::chess::ORIG_BOARD_ARRAY
}

pub fn update_board_data(row: u8, col: u8, piece_index: u8) {
    // println!("update 行{row} 列{col} for piece:{piece_index}");
    let index = crate::chess::get_board_pos_from_row_col(row, col);
    BOARD_ARRAY.lock().unwrap()[index as usize] = piece_index;
    // println!("update ok!");
}

pub fn update_player_data(player: String) {
    println!("update_player_data:{player}");
    crate::chess::set_player_by_str(&player);
}

//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓test↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
pub fn test_conflict_1(s: String) -> bool {
    return true;
}
pub fn test_string_func_1(x: String) {
    println!("test implicit parameter conflicts");
}
// pub fn test_conflict_1(s: String) -> bool {
//     return true;
// }

// pub fn test_conflict_2(s: String) -> bool {
//     return true;
// }
//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑test↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
