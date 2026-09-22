#import "../../codly.typ" as codly

#set page(height: auto, margin: 5pt, width: 250pt)

#codly.new(highlights: ((line: 2, start: 3, label: <hello>),), ```rs
pub fn main() {
  println!("Hello, World!");
}
```)
