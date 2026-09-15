#import "../../codly.typ" as codly
#set page(width: 240pt, height: auto, margin: 5pt)

#show: codly.line-set_(fill: red)

#codly.new(```rs
pub fn main() {
  println!("Hello, World!");
}
```)
