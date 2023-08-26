use std::assert_eq;

use const_format::concatcp;

const MSG: &str = concatcp!("Hello", ",", "world!");
fn main() {
    let res = path_lib::add(1, 2);
    assert_eq!(res, 3);
    println!("{MSG}");
}
