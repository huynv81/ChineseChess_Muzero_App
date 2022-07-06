// use crate::ucci::execute;

// pub fn launch_ucci_engine(engine_path: String) -> bool {
//     println!("引擎路径是：{engine_path}");
//     return execute(&engine_path);
// }
// pub fn test_get_output() -> String {
//     let mut command = Command::new("date");
//     let output = command.output().unwrap();
//     let x = std::str::from_utf8(&output.stdout[..]).unwrap();
//     x.into()
// }

use flutter_rust_bridge::support::lazy_static;
use flutter_rust_bridge::StreamSink;

//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓test↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
pub fn test_normal_func(x: u8) {
    println!("测试字符串");
}

pub fn test_conflict(x: u8) {
    println!("testing");
}

// pub fn test_duplicated2(x: u8) {
//     println!("testing");
// }

pub fn test_string_func(x: String) {
    println!("test parameter conflicts");
}

// pub fn test_conflict_1(s: String) -> bool {
//     return true;
// }
//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑test↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

pub struct LogEntry {
    pub time_millis: i64,
    pub level: i32,
    pub tag: String,
    pub msg: String,
}

use anyhow::Result;
use std::{thread::sleep, time::Duration};

const ONE_SECOND: Duration = Duration::from_secs(1);

// can't omit the return type yet, this is a bug
pub fn tick(sink: StreamSink<i32>) -> Result<()> {
    let mut ticks = 0;
    loop {
        sink.add(ticks);
        sleep(ONE_SECOND);
        if ticks == i32::MAX {
            break;
        }
        ticks += 1;
        println!("TICK IS {:.0}", ticks);
    }
    Ok(())
}

pub fn test_string_func_2(x: String) {
    println!("test implicit parameter conflicts");
}
