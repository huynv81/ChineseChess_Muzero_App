use flutter_rust_bridge::StreamSink;

use futures_util::stream::StreamExt;

use log::{debug, error, info, warn};
use once_cell::sync::Lazy;
use process_stream::{Process, ProcessExt};

use core::time;
use std::process::Stdio;
use std::sync::{Arc, Mutex};
use std::thread;

use tokio::io::AsyncWriteExt;

static LISTENER: Lazy<Arc<Mutex<Option<StreamSink<String>>>>> = Lazy::new(Default::default);
static COMMAND: Lazy<Arc<Mutex<String>>> = Lazy::new(Default::default);
static FLAG: Lazy<Arc<Mutex<bool>>> = Lazy::new(Default::default);
static PROCESS_LOADED: Lazy<Arc<Mutex<bool>>> = Lazy::new(Default::default);
static FEEDBACK: Lazy<Arc<Mutex<String>>> = Lazy::new(Default::default);

// crate::init_logger(&"./logs/").expect("日志模块初始化失败！");

// refer:https://github.com/fzyzcjy/flutter_rust_bridge/issues/517
// refer:http://cjycode.com/flutter_rust_bridge/feature/stream.html
// refer:http://cjycode.com/flutter_rust_bridge/feature/async_rust.html
#[tokio::main(flavor = "current_thread")]
pub async fn subscribe_ucci_engine(
    engine_path: String,
    listener: StreamSink<String>,
) -> anyhow::Result<()> {
    (*LISTENER.lock().unwrap()) = Some(listener);
    warn!("已捕获监听程序");

    info!("将打开的引擎路径为：{engine_path}");
    let mut process = Process::new(engine_path);
    process.stdin(Stdio::piped());
    warn!("已打开引擎进程");

    let (reader_thread, writer_thread) = if let Some(ref mut listener) = *LISTENER.lock().unwrap() {
        let cloned_listener = listener.clone(); // 必须clone,否则无法在async move中使用
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
                        info!("engine反馈： {}", feedback_str);
                        *FEEDBACK.lock().unwrap() = feedback_str.clone();
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
                if *FLAG.lock().unwrap() {
                    let cmd_str = (*COMMAND.lock().unwrap()).clone();
                    let cmd_byte = cmd_str.as_bytes();
                    info!("执行命令：{cmd_str}");
                    if let Err(e) = writer.write(cmd_byte).await {
                        error!("写入命令{cmd_str}异常: {e}");
                        return;
                    }
                    (*FLAG.lock().unwrap()) = false;
                }
            }
        });
        warn!("已监听ucci进程输入");

        (reader_thread, writer_thread)
    } else {
        *PROCESS_LOADED.lock().unwrap() = false;
        error!("监听程序读取出错！");
        panic!("监听程序读取出错！");
    };

    *PROCESS_LOADED.lock().unwrap() = true;
    info!("引擎启动");

    reader_thread.await.expect("read异常退出");
    writer_thread.await.expect("write异常退出");

    *PROCESS_LOADED.lock().unwrap() = false;
    info!("引擎退出");

    Ok(())
}

pub fn write_to_process(command: String, msec: u32, check_str_option: Option<String>) -> bool {
    if !command.is_empty() {
        *COMMAND.lock().unwrap() = format!("{command}\r\n");
        *FLAG.lock().unwrap() = true;

        // 反馈响应
        if let Some(check_str) = &check_str_option {
            let now = std::time::SystemTime::now();
            let sleep_msec = time::Duration::from_millis(200);
            while now.elapsed().unwrap().as_millis() < msec as u128 {
                if check_str == &(*FEEDBACK.lock().unwrap()) {
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
pub fn is_process_loaded(msec: u32) -> bool {
    let now = std::time::SystemTime::now();
    let sleep_msec = time::Duration::from_millis(200);
    while now.elapsed().unwrap().as_millis() < msec as u128 {
        if *PROCESS_LOADED.lock().unwrap() {
            return true;
        }
        thread::sleep(sleep_msec);
    }
    false
}

pub fn is_process_unloaded(msec: u32) -> bool {
    let now = std::time::SystemTime::now();
    let sleep_msec = time::Duration::from_millis(200);
    while now.elapsed().unwrap().as_millis() < msec as u128 {
        if !(*PROCESS_LOADED.lock().unwrap()) {
            return true;
        }
        thread::sleep(sleep_msec);
    }
    false
}
