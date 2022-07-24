use flutter_rust_bridge::StreamSink;

use futures_util::stream::StreamExt;

use log::{debug, error, info, warn};
use once_cell::sync::Lazy;
use process_stream::{Process, ProcessExt};

use std::process::Stdio;
use std::sync::{Arc, Mutex};

use tokio::io::AsyncWriteExt;

static LISTENER: Lazy<Arc<Mutex<Option<StreamSink<String>>>>> = Lazy::new(Default::default);
static COMMAND: Lazy<Arc<Mutex<String>>> = Lazy::new(Default::default);
static FLAG: Lazy<Arc<Mutex<bool>>> = Lazy::new(Default::default);
static PROCESS_LAUNCHED: Lazy<Arc<Mutex<bool>>> = Lazy::new(Default::default);
// static COMMAND_FEEDBACK: Lazy<Arc<Mutex<bool>>> = Lazy::new(Default::default);
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
            // loop {
            while let Some(value) = stream.next().await {
                let feedback_str = (*value).to_string();
                info!("engine反馈： {}", feedback_str);
                cloned_listener.add(feedback_str.clone());
                *FEEDBACK.lock().unwrap() = feedback_str;
            }
            // }
        });
        warn!("已监听ucci进程输出");

        //
        let mut writer = process.take_stdin().unwrap();
        let writer_thread = tokio::spawn(async move {
            loop {
                if *FLAG.lock().unwrap() {
                    let v = (*COMMAND.lock().unwrap()).clone();
                    let cmd_byte = v.as_bytes();
                    // info!("执行命令：{cmd_byte:?}");
                    writer.write(cmd_byte).await.unwrap();
                    (*FLAG.lock().unwrap()) = false;
                }
            }

        });
        warn!("已监听ucci进程输入");

        (reader_thread, writer_thread)
    } else {
        *PROCESS_LAUNCHED.lock().unwrap() = false;
        error!("监听程序读取出错！");
        panic!("监听程序读取出错！");
    };

    *PROCESS_LAUNCHED.lock().unwrap() = true;

    reader_thread.await.unwrap();
    writer_thread.await.unwrap();

    Ok(())
}

// #[tokio::main(flavor = "current_thread")]
// pub async fn write_to_process(command: String) {
pub fn write_to_process(command: String, msec: u32, check_str_option: Option<String>) -> bool {
    if !command.is_empty() {
        *COMMAND.lock().unwrap() = format!("{command}\r\n");
        *FLAG.lock().unwrap() = true;

        // 反馈响应
        (*FEEDBACK.lock().unwrap()).clear();
        let now = std::time::SystemTime::now();
        while now.elapsed().unwrap().as_millis() < msec as u128 {
            if !(*FEEDBACK.lock().unwrap()).is_empty() {
                if let Some(check_str) = &check_str_option {
                    if check_str.contains(&(*FEEDBACK.lock().unwrap())) {
                        return true;
                    }
                } else {
                    return true;
                }
            }
        }
        return false;
    }
    true
}

pub fn is_processe_launched(msec: u32) -> bool {
    let now = std::time::SystemTime::now();
    while now.elapsed().unwrap().as_millis() < msec as u128 {
        if *PROCESS_LAUNCHED.lock().unwrap() {
            return true;
        }
    }
    false
}
