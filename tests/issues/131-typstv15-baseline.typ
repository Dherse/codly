#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)

#codly.new(
  highlights: (
    (line: 3, start: 3, end: 10, fill: orange),
  ),
  ```rust
  pub fn main() {
    println!("Hello, world!");
    println!("Hello, world!");
  }
  ```,
)
