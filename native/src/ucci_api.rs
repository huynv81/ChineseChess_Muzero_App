use flutter_rust_bridge::StreamSink;

use futures_util::stream::StreamExt;

use log::{debug, error, info, warn};
use once_cell::sync::Lazy;
use process_stream::{Process, ProcessExt};

use core::time;
use parking_lot::{MappedMutexGuard, Mutex, MutexGuard};
use std::process::Stdio;
use std::sync::Arc;

use std::thread;

use tokio::io::AsyncWriteExt;

use crate::util_api::Player;

static RED_LISTENER: Lazy<Arc<Mutex<Option<StreamSink<String>>>>> = Lazy::new(Default::default);
static BLACK_LISTENER: Lazy<Arc<Mutex<Option<StreamSink<String>>>>> = Lazy::new(Default::default);
static COMMAND: Lazy<Arc<Mutex<String>>> = Lazy::new(Default::default);
static RED_FLAG: Lazy<Arc<Mutex<bool>>> = Lazy::new(Default::default);
static BLACK_FLAG: Lazy<Arc<Mutex<bool>>> = Lazy::new(Default::default);
static RED_PROCESS_LOADED: Lazy<Arc<Mutex<bool>>> = Lazy::new(Default::default);
static BLACK_PROCESS_LOADED: Lazy<Arc<Mutex<bool>>> = Lazy::new(Default::default);
static FEEDBACK: Lazy<Arc<Mutex<String>>> = Lazy::new(Default::default);
//
static RED_ENGINE_NAME: Lazy<Arc<Mutex<String>>> = Lazy::new(Default::default);
static BLACK_ENGINE_NAME: Lazy<Arc<Mutex<String>>> = Lazy::new(Default::default);

// fn get_listener(player: Player) -> MutexGuard<Option<StreamSink<String>>> {
fn get_cloned_listener(player: Player) -> Option<StreamSink<String>> {
    match player {
        Player::Red => (*RED_LISTENER.lock()).clone(),
        Player::Black => (*BLACK_LISTENER.lock()).clone(),
    }
}

fn set_listener(player: Player, listener: StreamSink<String>) {
    match player {
        Player::Red => (*RED_LISTENER.lock()) = Some(listener),
        Player::Black => (*BLACK_LISTENER.lock()) = Some(listener),
    }
}

// refer:https://github.com/fzyzcjy/flutter_rust_bridge/issues/517
// refer:http://cjycode.com/flutter_rust_bridge/feature/stream.html
// refer:http://cjycode.com/flutter_rust_bridge/feature/async_rust.html
// #[tokio::main(flavor = "current_thread")]
#[tokio::main]
pub async fn subscribe_ucci_engine(
    player: Player,
    engine_path: String,
    listener: StreamSink<String>,
) -> anyhow::Result<()> {
    debug!("玩家：{:?}", player);
    debug!("线程：{:?}", thread::current().id());

    set_listener(player, listener);
    warn!("已捕获监听程序");

    info!("将打开的引擎路径为：{engine_path}");
    let mut process = Process::new(engine_path);
    process.stdin(Stdio::piped());
    warn!("已打开引擎进程");

    let (reader_thread, writer_thread) = if let Some(cloned_listener) = get_cloned_listener(player)
    {
        let mut stream = process.spawn_and_stream().unwrap();
        let reader_thread = tokio::spawn(async move {
            loop {
                match stream.next().await {
                    Some(value) => {
                        if value.is_exit() {
                            warn!("检测到空输出");
                            break;
                        }
                        let feedback_str = (*value).to_string();
                        // TODO: "utf-8"以外的编码如何处理
                        if feedback_str.contains("id name ") {
                            let string_vec = feedback_str
                                .split(" ")
                                .filter(|&s| !s.is_empty())
                                .map(|s| s.to_string())
                                .collect::<Vec<_>>();
                            set_engine_name(player, &string_vec[2]);
                        }
                        info!("engine反馈： {}", feedback_str);
                        *FEEDBACK.lock() = feedback_str.clone();
                        cloned_listener.add(feedback_str);
                    }
                    // TODO：本意希望进程异常时触发，但好像不会触发
                    None => {
                        warn!("engine[异常]反馈：none");
                        return;
                    }
                }
                // thread::sleep(time::Duration::from_millis(200));
            }
        });
        warn!("已监听ucci进程输出");

        //
        let mut writer = process.take_stdin().unwrap();
        let writer_thread = tokio::spawn(async move {
            loop {
                if get_flag_lock(player) {
                    let cmd_str = (*COMMAND.lock()).clone();
                    let cmd_byte = cmd_str.as_bytes();
                    info!("执行命令：{cmd_str}");
                    if let Err(e) = writer.write(cmd_byte).await {
                        error!("写入命令{cmd_str}异常: {e}");
                        return;
                    }
                    set_flag_lock(player, false);
                }
            }
        });
        warn!("已监听ucci进程输入");

        (reader_thread, writer_thread)
    } else {
        set_process_loaded(player, false);
        error!("监听程序读取出错！");
        panic!("监听程序读取出错！");
    };

    set_process_loaded(player, true);
    info!("引擎启动");

    reader_thread.await.expect("read异常退出");
    writer_thread.await.expect("write异常退出");

    set_process_loaded(player, false);
    info!("引擎退出");

    Ok(())
}

fn get_flag_lock(player: Player) -> bool {
    match player {
        Player::Red => *RED_FLAG.lock(),
        Player::Black => *BLACK_FLAG.lock(),
    }
}

fn set_flag_lock(player: Player, is_lock: bool) {
    match player {
        Player::Red => (*RED_FLAG.lock()) = is_lock,
        Player::Black => (*BLACK_FLAG.lock()) = is_lock,
    }
}

pub fn write_to_process(
    command: String,
    msec: u32,
    player: Player,
    check_str_option: Option<String>,
) -> bool {
    if !command.is_empty() {
        *COMMAND.lock() = format!("{command}\r\n");
        set_flag_lock(player, true);

        // 反馈响应
        if let Some(check_str) = &check_str_option {
            let now = std::time::SystemTime::now();
            let sleep_msec = time::Duration::from_millis(200);
            while now.elapsed().unwrap().as_millis() < msec as u128 {
                if check_str == &(*FEEDBACK.lock()) {
                    // debug!("反馈检查{check_str}成功");
                    return true;
                }
                thread::sleep(sleep_msec);
                // return false;这里不能直接返回false，比如“ucciok”就是在好几个输出后才有的值
            }
            // debug!("反馈检查{check_str}失败");
            return false;
        } else {
            // debug!("无反馈检查，返回true");
            return true;
        }
    }
    true
}

//只要引擎启动了，即使没有ucciok也返回true
pub fn is_process_loaded(msec: u32, player: Player) -> bool {
    let now = std::time::SystemTime::now();
    let sleep_msec = time::Duration::from_millis(200);
    while now.elapsed().unwrap().as_millis() < msec as u128 {
        match player {
            Player::Red => {
                if *RED_PROCESS_LOADED.lock() {
                    return true;
                }
            }
            Player::Black => {
                if *BLACK_PROCESS_LOADED.lock() {
                    return true;
                }
            }
        }

        thread::sleep(sleep_msec);
    }
    false
}

pub fn is_process_unloaded(msec: u32, player: Player) -> bool {
    let now = std::time::SystemTime::now();
    let sleep_msec = time::Duration::from_millis(200);
    while now.elapsed().unwrap().as_millis() < msec as u128 {
        match player {
            Player::Red => {
                if *RED_PROCESS_LOADED.lock() {
                    return true;
                }
            }
            Player::Black => {
                if *BLACK_PROCESS_LOADED.lock() {
                    return true;
                }
            }
        }
        thread::sleep(sleep_msec);
    }
    false
}

fn set_process_loaded(player: Player, is_loaded: bool) {
    match player {
        Player::Red => *RED_PROCESS_LOADED.lock() = is_loaded,
        Player::Black => *BLACK_PROCESS_LOADED.lock() = is_loaded,
    }
}

pub fn get_engine_name(player: Player) -> String {
    match player {
        Player::Red => (*RED_ENGINE_NAME.lock()).clone(),
        Player::Black => (*BLACK_ENGINE_NAME.lock()).clone(),
    }
}

fn set_engine_name(player: Player, name: &str) {
    match player {
        Player::Red => *RED_ENGINE_NAME.lock() = name.to_owned(),
        Player::Black => *BLACK_ENGINE_NAME.lock() = name.to_owned(),
    }
}
