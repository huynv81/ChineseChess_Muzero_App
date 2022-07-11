use std::sync::Mutex;

use once_cell::sync::Lazy;

static FLAG: Lazy<Mutex<bool>> = Lazy::new(Default::default);

pub fn init_logger() {
    println!("调用日志注册前");
    if *FLAG.lock().unwrap() == false {
        crate::init_logger_inside(&"./logs/").expect("日志模块初始化失败！");
        *FLAG.lock().unwrap() = true;
        println!("调用日志注册后");
    }
}

// 为激活本模块init_logger()而写的伪函数
pub fn activate_api() {}
