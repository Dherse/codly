#import "../../codly.typ" as codly
#set page(width: 300pt, height: auto)

#show: codly.line-set_(fill: red)

#codly.new(```rs
pub fn main() {
  println!("Hello, World!");
}
```)
