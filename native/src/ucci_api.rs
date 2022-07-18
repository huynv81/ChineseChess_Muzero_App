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

    let mut process = Process::new(engine_path);
    process.stdin(Stdio::piped());
    warn!("已打开引擎进程");

    let (reader_thread, writer_thread) = if let Some(ref mut listener) = *LISTENER.lock().unwrap() {
        let cloned_listener = listener.clone(); // 必须clone,否则无法在async move中使用
        let mut stream = process.spawn_and_stream().unwrap();
        let reader_thread = tokio::spawn(async move {
            loop {
                while let Some(value) = stream.next().await {
                    info!("收到反馈： {}", value);
                    cloned_listener.add((*value).into());
                }
            }
        });
        warn!("已监听ucci进程输出");

        //
        let mut writer = process.take_stdin().unwrap();
        let writer_thread = tokio::spawn(async move {
            loop {
                if *FLAG.lock().unwrap() {
                    let cmd_str = format!("{}\r\n", (*COMMAND.lock().unwrap()));
                    let cmd = cmd_str.as_bytes();
                    writer.write(cmd).await.unwrap();
                    info!("执行命令：{cmd_str}");
                    (*FLAG.lock().unwrap()) = false;
                }
            }
        });
        warn!("已监听ucci进程输入");

        listener.add("hookOk".into());
        warn!("已发回hookOk");


        (reader_thread, writer_thread)
    } else {
        error!("监听程序读取出错！");
        panic!("监听程序读取出错！");
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
