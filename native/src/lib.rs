use std::sync::Once;

mod chess;
mod ucci;

mod rule_api;
mod ucci_api;
mod util_api;

mod gened_rule_api;
mod gened_ucci_api;
mod gened_util_api;

static INIT_LOGGER_ONCE: Once = Once::new();
fn init_logger(path: &str) {
    INIT_LOGGER_ONCE.call_once(|| {
        std::fs::create_dir_all(path).expect("创建日志目录失败！");
        let d = fern::Dispatch::new().format(|out, message, record| {
            out.finish(format_args!(
                "{}[{}] {}",
                chrono::Local::now().format("%Y/%m/%d %H:%M:%S "),
                record.level(),
                message
            ))
        });

        #[cfg(debug_assertions)]
        d.level(log::LevelFilter::Debug)
            .chain(fern::DateBased::new(path, "%Y-%m-%d.log"))
            .chain(std::io::stdout())
            .apply()
            .expect("日志模块配置失败！");

        #[cfg(not(debug_assertions))]
        d.level(log::LevelFilter::Info)
            .chain(fern::DateBased::new(path, "%Y-%m-%d.log"))
            .apply()
            .expect("日志模块配置失败！");

        std::panic::set_hook(Box::new(|m| {
            log::error!("{}", m);
        }));
    });
}
