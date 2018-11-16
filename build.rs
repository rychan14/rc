use std::process::Command;

fn main() {
  Command::new("elm")
    .arg("make")
    .arg("elm-src/Main.elm")
    .arg("--output=dist/elm.js")
    .spawn()
    .expect("elm build failed");
}