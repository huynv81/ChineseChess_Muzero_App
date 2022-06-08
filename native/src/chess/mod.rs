use num_derive::FromPrimitive;
use num_traits::FromPrimitive;
use once_cell::sync::Lazy;
use std::ops::Deref;
use std::sync::Mutex;

pub static BOARD_ARRAY: Lazy<Mutex<[usize; 256]>> = Lazy::new(|| Mutex::new([0; 256]));
pub static PLAYER: Lazy<Mutex<Player>> = Lazy::new(|| Mutex::new(Player::Unknown));

pub const ORIG_BOARD_ARRAY: [usize; 256] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 19, 18, 17, 16, 17, 18, 19, 20, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 21, 0,
    0, 0, 0, 0, 0, 0, 0, 22, 0, 22, 0, 22, 0, 22, 0, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 0, 14, 0, 14, 0,
    14, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 13, 0, 0, 0, 0, 0, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 11, 10, 9, 8, 9, 10, 11, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

// TODO： name style
const CC_KING_DELTA: [i32; 4] = [-16, -1, 1, 16];
const CC_ADVISOR_DELTA: [i32; 4] = [-17, -15, 15, 17];

//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓注意这2个数组的每个元素位置需要“一一对应”↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
const CC_BISHOP_DELTA: [i32; 4] = [-0x22, -0x1e, 0x1e, 0x22];
const CC_BISHOP_EYE_DELTA: [i32; 4] = [-17, -15, 15, 17];
//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑注意这2个数组的每个元素位置需要“一一对应”↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓注意这2个数组的每个元素位置需要“一一对应”↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
const ccKnightDelta: [[i32; 2]; 4] = [[-33, -31], [-18, 14], [-14, 18], [31, 33]];
const ccKnightFootDelta: [i32; 4] = [-16, -1, 1, 16];
//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑注意这2个数组的每个元素位置需要“一一对应”↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

const BOARD_LEFT_UP_POS: usize = 0x33;
const BOARD_RIGHT_DOWN_POS: usize = 0xcb;

// 判断棋子是否在九宫的矩阵
const FORT_MATRIX: [u8; 256] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

// 判断棋子是否在棋盘中的数组
const IN_BOARD_MATRIX: [u8; 256] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

// 判断棋子是否在九宫中
fn is_pos_in_fort(pos: usize) -> bool {
    return FORT_MATRIX[pos] != 0;
}

fn is_pos_in_board(pos: usize) -> bool {
    return IN_BOARD_MATRIX[pos] != 0;
}

fn is_pos_in_home_side(player: &std::sync::MutexGuard<Player>, pos: usize) -> bool {
    let player_ref = player.deref();
    match player_ref {
        Player::Unknown => panic!("出现了未知的player"),
        _ => {
            let player_num = player_ref.clone() as usize;
            (pos & 0x80) != (player_num << 7)
        }
    }
}

/// 本函数一次仅检查一个方向的位置
fn is_pos_stuck(
    board_array: &std::sync::MutexGuard<[usize; 256]>,
    src_pos: usize,
    stuck_offset: i32,
) -> bool {
    let each_stuck_pos = (src_pos as i32 + stuck_offset) as usize;
    let piece = get_side_piece_by_pos(board_array, each_stuck_pos);
    if piece != SidePieceType::None {
        return true;
    }
    false
}

/// 格子水平镜像---即根据红黑方“前进”一格的16进制表示模式下的index
fn SQUARE_FORWARD(player: &std::sync::MutexGuard<Player>, src_pos: usize) -> usize {
    let player_ref = player.deref();

    match player_ref {
        Player::Unknown => panic!("出现了未知的player"),
        _ => {
            let player_num = player_ref.clone() as usize;
            src_pos - 16 + (player_num << 5)
        }
    }
}

fn is_self_piece_by_pos(
    board_array: &std::sync::MutexGuard<[usize; 256]>,
    player: &std::sync::MutexGuard<Player>,
    board_pos: usize,
) -> bool {
    let red_black_piece_index = get_side_piece_by_pos(board_array, board_pos);
    return !(red_black_piece_index as usize & get_piece_offset_tag(player) == 0);
}

/// 进而返回红黑标记(红子返回8，黑子返回16)
fn get_piece_offset_tag(player: &std::sync::MutexGuard<Player>) -> usize {
    let player_ref = player.deref();
    let player_index = match player_ref {
        Player::Red => 0,
        Player::Black => 1,
        Player::Unknown => panic!("玩家标识符为Unkown！"),
    };
    return 8 + (player_index << 3);
}

// ----------------------分割线----------------------

use phf::phf_map;

static ROW_NUM_TO_STR_MAP: phf::Map<u8, u8> = phf_map! {
    1u8 => 9,
    2u8 => 8,
    3u8 => 7,
    4u8 => 6,
    5u8 => 5,
    6u8 => 4,
    7u8 => 3,
    8u8 => 2,
    9u8 => 1,
    10u8 => 0,
};
static COL_NUM_TO_STR_MAP: phf::Map<u8, char> = phf_map! {
    1u8 => 'a',
    2u8 => 'b',
    3u8 => 'c',
    4u8 => 'd',
    5u8 => 'e',
    6u8 => 'f',
    7u8 => 'g',
    8u8 => 'h',
    9u8 => 'i',
};

fn get_row_col_from_board_pos(index: usize) -> (usize, usize) {
    // row col是从(左上角)1开始计数的
    let row = (index) / 16 - 2;
    let col = (index) % 16 - 2;
    (row, col)
}

// 转换为ICCS棋谱表示法：https://www.xqbase.com/protocol/cchess_move.htm
pub fn get_english_move_str_from_pos(src_pos: usize, dst_pos: usize) -> String {
    let (src_row, src_col) = get_row_col_from_board_pos(src_pos);
    let (dst_row, dst_col) = get_row_col_from_board_pos(dst_pos);

    // println!("nei起始行列是：行{src_row} 列{src_col}");
    // println!("nei目标行列是：行{dst_row} 列{dst_col}");

    let src_move_str = get_pos_str_from_row_col(src_row, src_col);
    let dst_move_str = get_pos_str_from_row_col(dst_row, dst_col);

    format!("{src_move_str}{dst_move_str}")
}

fn get_pos_str_from_row_col(row: usize, col: usize) -> String {
    format!(
        "{}{}",
        COL_NUM_TO_STR_MAP[&(col as u8)],
        ROW_NUM_TO_STR_MAP[&(row as u8)],
    )
}

pub fn get_board_pos_from_row_col(row: usize, col: usize) -> usize {
    let index = (16 * (row + 2) + 3 + col) - 1;
    index
}

pub fn set_player_by_str(player_str: &str) {
    let mut player = PLAYER.lock().unwrap();
    *player = match player_str {
        "b" => Player::Black,
        _ => Player::Red,
    };
}

pub fn get_piece_all_valid_moves(
    board_array: &std::sync::MutexGuard<[usize; 256]>,
    src_pos: usize, //被查棋子所在的位置
    unside_src_piece: PieceType,
) -> Vec<String> {
    let mut valid_move_vec = Vec::new();
    let player = &PLAYER.lock().unwrap();
    match unside_src_piece {
        PieceType::King => {
            for offset in CC_KING_DELTA {
                // 检查是否在九宫格内
                let dst_pos_to_check = (src_pos as i32 + offset) as usize;
                if !is_pos_in_fort(dst_pos_to_check) {
                    continue;
                }
                // 检查目标位置是否为自身棋子，是的话肯定不合理
                if !is_self_piece_by_pos(board_array, player, dst_pos_to_check) {
                    let move_str = get_english_move_str_from_pos(src_pos, dst_pos_to_check);
                    valid_move_vec.push(move_str);
                }
            }
        }
        PieceType::Advisor => {
            for offset in CC_ADVISOR_DELTA {
                // 检查是否在九宫格内
                let dst_pos_to_check = (src_pos as i32 + offset) as usize;
                if !is_pos_in_fort(dst_pos_to_check) {
                    continue;
                }
                // 检查目标位置是否为自身棋子，是的话肯定不合理
                if !is_self_piece_by_pos(board_array, player, dst_pos_to_check) {
                    let move_str = get_english_move_str_from_pos(src_pos, dst_pos_to_check);
                    valid_move_vec.push(move_str);
                }
            }
        }
        PieceType::Bishop => {
            for (offset, eye_stuck_offset) in CC_BISHOP_DELTA.iter().zip(CC_BISHOP_EYE_DELTA.iter())
            {
                // 是否在棋盘中
                let dst_pos_to_check = (src_pos as i32 + offset) as usize;
                if !is_pos_in_board(dst_pos_to_check) {
                    continue;
                }
                // 是否过河了
                if !is_pos_in_home_side(player, dst_pos_to_check) {
                    continue;
                }
                // 是否塞象眼
                if is_pos_stuck(board_array, src_pos, *eye_stuck_offset) {
                    continue;
                }
                // 检查目标位置是否为自身棋子，是的话肯定不合理
                if !is_self_piece_by_pos(board_array, player, dst_pos_to_check) {
                    let move_str = get_english_move_str_from_pos(src_pos, dst_pos_to_check);
                    valid_move_vec.push(move_str);
                }
            }
        }
        PieceType::Knight => {
            for (each_offset_pair, knight_stuck_offset) in
                ccKnightDelta.iter().zip(ccKnightFootDelta.iter())
            {
                // 是否在棋盘中
                for each_offset in each_offset_pair {
                    let dst_pos_to_check = (src_pos as i32 + each_offset) as usize;
                    if !is_pos_in_board(dst_pos_to_check) {
                        continue;
                    }
                    // 是否瘪马脚
                    if is_pos_stuck(board_array, src_pos, *knight_stuck_offset) {
                        continue;
                    }
                    // 检查目标位置是否为自身棋子，是的话肯定不合理
                    if !is_self_piece_by_pos(board_array, player, dst_pos_to_check) {
                        let move_str = get_english_move_str_from_pos(src_pos, dst_pos_to_check);
                        valid_move_vec.push(move_str);
                    }
                }
            }
        }
        PieceType::Rook => {
            for offset in CC_KING_DELTA {
                let mut dst_pos_to_check = (src_pos as i32 + offset) as usize;

                while is_pos_in_board(dst_pos_to_check) {
                    let dst_piece = get_side_piece_by_pos(board_array, dst_pos_to_check);
                    if dst_piece == SidePieceType::None {
                        let move_str = get_english_move_str_from_pos(src_pos, dst_pos_to_check);
                        valid_move_vec.push(move_str);
                    } else {
                        if !is_self_piece_by_pos(board_array, player, dst_pos_to_check) {
                            let move_str = get_english_move_str_from_pos(src_pos, dst_pos_to_check);
                            valid_move_vec.push(move_str);
                        }
                        break;
                    }
                    dst_pos_to_check = (dst_pos_to_check as i32 + offset) as usize;
                }
            }
        }
        PieceType::Cannon => {
            for offset in CC_KING_DELTA {
                let mut dst_pos_to_check = (src_pos as i32 + offset) as usize;

                // 校验仅平移时的可行招法
                while is_pos_in_board(dst_pos_to_check) {
                    let dst_piece = get_side_piece_by_pos(board_array, dst_pos_to_check);
                    if dst_piece == SidePieceType::None {
                        let move_str = get_english_move_str_from_pos(src_pos, dst_pos_to_check);
                        valid_move_vec.push(move_str);
                    } else {
                        break;
                    }
                    dst_pos_to_check = (dst_pos_to_check as i32 + offset) as usize;
                }

                // 校验隔子打炮的可行招法
                dst_pos_to_check = (dst_pos_to_check as i32 + offset) as usize;
                while is_pos_in_board(dst_pos_to_check) {
                    let dst_piece = get_side_piece_by_pos(board_array, dst_pos_to_check);
                    if dst_piece != SidePieceType::None {
                        if !is_self_piece_by_pos(board_array, player, dst_pos_to_check) {
                            let move_str = get_english_move_str_from_pos(src_pos, dst_pos_to_check);
                            valid_move_vec.push(move_str);
                        }
                        break;
                    }
                    dst_pos_to_check = (dst_pos_to_check as i32 + offset) as usize;
                }
            }
        }
        PieceType::Pawn => {
            // 未过河的招法判断
            let mut dst_pos_to_check = SQUARE_FORWARD(player, src_pos);
            if is_pos_in_board(dst_pos_to_check) {
                if !is_self_piece_by_pos(board_array, player, dst_pos_to_check) {
                    let move_str = get_english_move_str_from_pos(src_pos, dst_pos_to_check);
                    valid_move_vec.push(move_str);
                }
            }

            // 过河情况的左右2个方向判断
            if !is_pos_in_home_side(player, src_pos) {
                for horizontal_offset in [-1i32, 1] {
                    dst_pos_to_check = (src_pos as i32 + horizontal_offset) as usize;
                    if is_pos_in_board(dst_pos_to_check) {
                        if !is_self_piece_by_pos(board_array, player, dst_pos_to_check) {
                            let move_str = get_english_move_str_from_pos(src_pos, dst_pos_to_check);
                            valid_move_vec.push(move_str);
                        }
                    }
                }
            }
        }
        _ => panic!("未知的棋子类型"),
    }

    valid_move_vec
}

/// 根据传入的位置中的棋子(不区分红黑方)，返回PieceType
/// 若输入的位置没有棋子，则返回PieceType::None
fn get_side_piece_by_pos(
    board_array: &std::sync::MutexGuard<[usize; 256]>,
    board_pos: usize,
) -> SidePieceType {
    let board_piece = board_array[board_pos];
    match FromPrimitive::from_usize(board_piece) {
        Some(piece_type) => piece_type,
        None => SidePieceType::None,
    }
}

pub fn get_unside_piece_by_pos(
    board_array: &std::sync::MutexGuard<[usize; 256]>,
    board_pos: usize,
) -> PieceType {
    let side_piece = get_side_piece_by_pos(board_array, board_pos); //区分红黑方的棋子编号
    get_unside_piece_by_side_piece(side_piece)
}

#[derive(PartialEq, Debug, Clone, Copy)]
pub enum Player {
    Red,
    Black,
    Unknown,
}

#[derive(PartialEq, Debug, FromPrimitive)]
pub enum PieceType {
    King = 0,
    Advisor = 1,
    Bishop = 2,
    Knight = 3,
    Rook = 4,
    Cannon = 5,
    Pawn = 6,
    //
    None,
}

#[derive(PartialEq, PartialOrd, Debug, Clone, Copy, FromPrimitive)]
enum SidePieceType {
    None = 0,
    RedKing = 8,
    RedAdvisor = 9,
    RedBishop = 10,
    RedKnight = 11,
    RedRook = 12,
    RedCannon = 13,
    RedPawn = 14,

    BlackKing = 16,
    BlackAdvisor = 17,
    BlackBishop = 18,
    BlackKnight = 19,
    BlackRook = 20,
    BlackCannon = 21,
    BlackPawn = 22,
}

fn is_red_piece(side_piece: SidePieceType) -> bool {
    side_piece >= SidePieceType::RedKing && side_piece <= SidePieceType::RedPawn
}
fn is_black_piece(side_piece: SidePieceType) -> bool {
    side_piece >= SidePieceType::BlackKing && side_piece <= SidePieceType::BlackPawn
}

fn get_unside_piece_by_side_piece(side_piece: SidePieceType) -> PieceType {
    let unside_piece_pos = match side_piece {
        x if is_red_piece(x) => side_piece as usize - 8,
        x if is_black_piece(x) => side_piece as usize - 16,
        _ => return PieceType::None,
    };

    match FromPrimitive::from_usize(unside_piece_pos) {
        Some(piece_type) => piece_type,
        None => PieceType::None,
    }
}
