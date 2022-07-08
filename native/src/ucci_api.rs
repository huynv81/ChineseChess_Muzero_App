
use flutter_rust_bridge::support::lazy_static;
use flutter_rust_bridge::StreamSink;

pub struct LogEntry {
    pub time_millis: i64,
    pub level: i32,
    pub tag: String,
    pub msg: String,
}

use anyhow::Result;
use core::time;
use futures_util::stream::StreamExt;
use futures_util::Stream;
use once_cell::sync::Lazy;
use process_stream::{Process, ProcessExt, ProcessItem};
use std::pin::Pin;
use std::process::Stdio;
use std::sync::{Arc, Mutex};
use std::thread;
use std::{thread::sleep, time::Duration};
use tokio::io::AsyncWriteExt;
use tokio::process::ChildStdin;

static LISTENER: Lazy<Arc<Mutex<Option<StreamSink<String>>>>> = Lazy::new(|| Default::default());
static COMMAND: Lazy<Arc<Mutex<String>>> = Lazy::new(|| Default::default());
static FLAG: Lazy<Arc<Mutex<bool>>> = Lazy::new(|| Default::default());
// static COMMAND: Lazy<Arc<Mutex<Option<String>>>> = Lazy::new(|| Default::default());
// static PROCESS: Lazy<Arc<Mutex<Option<Process>>>> = Lazy::new(|| Default::default());
// static STREAM: Lazy<Arc<Mutex<Option<Pin<Box<dyn Stream<Item = ProcessItem> + Send>>>>>> =
// Lazy::new(|| Default::default());
// static WRITER: Lazy<Mutex<Option<ChildStdin>>> = Lazy::new(|| Default::default());

// refer:https://github.com/fzyzcjy/flutter_rust_bridge/issues/517
// refer:http://cjycode.com/flutter_rust_bridge/feature/stream.html
// refer:http://cjycode.com/flutter_rust_bridge/feature/async_rust.html
#[tokio::main(flavor = "current_thread")]
pub async fn register_ucci_engine(
    engine_path: String,
    listener: StreamSink<String>,
) -> anyhow::Result<()> {
    (*LISTENER.lock().unwrap()) = Some(listener);
    println!("已注册引擎");
    let p = r"D:\DATA\BaiduSyncdisk\project\personal\chinese_chess\ChineseChess_Muzero_App\assets\engine\XQAtom64 v1.0.6\XQAtom.exe";
    // // let p = r"D:\DATA\BaiduSyncdisk\project\personal\rust_cmd\target\debug\rust_cmd.exe";

    let mut process = Process::new(p);
    process.stdin(Stdio::piped());
    println!("已捕获process");

    let (reader_thread, writer_thread) = if let Some(ref mut listener) = *LISTENER.lock().unwrap() {
        let cloned_listener = listener.clone(); // 必须clone,否则无法在async move中使用
        let mut stream = process.spawn_and_stream().unwrap();
        let reader_thread = tokio::spawn(async move {
            loop {
                while let Some(value) = stream.next().await {
                    println!("收到： {}", value);
                    cloned_listener.add((*value).into());
                }
            }
        });
        println!("已监听process输出");

        //
        let mut writer = process.take_stdin().unwrap();
        let writer_thread = tokio::spawn(async move {
            loop {
                if (*FLAG.lock().unwrap()) == true {
                    let cmd_str = format!("{}\r\n", (*COMMAND.lock().unwrap()));
                    let cmd = cmd_str.as_bytes();
                    writer.write(cmd).await.unwrap();
                    println!("执行了{cmd_str}");
                    (*FLAG.lock().unwrap()) = false;
                }
            }
        });
        println!("已监听process输入");

        (reader_thread, writer_thread)
    } else {
        panic!("listener读取出错！");
    };

    reader_thread.await.unwrap();
    writer_thread.await.unwrap();

    Ok(())
}

#[tokio::main(flavor = "current_thread")]
pub async fn write_to_process(command: String) {
    if !command.is_empty() {
        *COMMAND.lock().unwrap() = command;
        *FLAG.lock().unwrap() = true;
    }
}
