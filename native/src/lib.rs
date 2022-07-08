// mod auto_api;
mod chess;
mod gened_rule_api; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
mod gened_ucci_api; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
mod rule_api;
mod ucci;
mod ucci_api;


/// 初始化示例：init_logger(&"./logs/").expect("日志模块初始化失败！");
pub fn init_logger(path: &str) -> Result<(), fern::InitError> {
    std::fs::create_dir_all(path).expect("创建日志目录失败！");
    let d = fern::Dispatch::new().format(|out, message, record| {
        out.finish(format_args!(
"{}[{}] {}",
            chrono::Local::now().format("%Y/%m/%d %H:%M:%S"),
            record.level(),
            message
        ))
    });

    #[cfg(debug_assertions)]
    d.level(log::LevelFilter::Debug)
        .chain(fern::DateBased::new(path, "%Y-%m-%d.log"))
        .chain(std::io::stdout())
        .apply()?;

    #[cfg(not(debug_assertions))]
    d.level(log::LevelFilter::Info)
        .chain(fern::DateBased::new(path, "%Y-%m-%d.log"))
        .apply()?;

    std::panic::set_hook(Box::new(|m| {
        log::error!("{}", m);
    }));

    Ok(())
}
