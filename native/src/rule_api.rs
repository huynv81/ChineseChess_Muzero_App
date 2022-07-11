use crate::chess::{get_piece_all_valid_moves, BOARD_ARRAY};

pub fn test_log_1(log: String) {
    log::info!("{}", log);
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
    contains
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
