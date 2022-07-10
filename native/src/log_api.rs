pub fn init_logger() {
    println!("调用日志注册");
    crate::init_logger_inside(&"./logs/").expect("日志模块初始化失败！");
    println!("调用日志注册2");
}

pub fn test_log_3(log: String) {
    log::info!("{}", log);
}
