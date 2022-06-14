use std::io::{Result, Write};
use std::process::{Command, ExitStatus};

// // 参考：https://stackoverflow.com/questions/53477846/start-another-program-then-quit
// // pub fn execute(exe: &str, args: &[&str]) -> Result<ExitStatus> {
// pub fn execute(exe: &str) -> bool {
//     println!("你好fangp");
//     // Command::new(exe).spawn() /* .wait() */
//     let mut process = Command::new(exe);
//     let output = process.output().unwrap();
//     if output.status.success() {
//         let s = String::from_utf8_lossy(&output.stdout);
//         print!("成功:\n{}", s);

//         println!("-------继续ucci---------");
//         process.cwd("ucci".into()).output().unwrap();
//         // process.stdin::<String>("ucci".into()).output().unwrap();

//         return true;
//     } else {
//         println!("引擎加载失败");
//         return false;
//     }
// }
