#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 300pt, height: auto, margin: 5pt)

#let code = ```rs
pub fn main() {
  println!("Hello, world!");
}
```

#codly.new(code)
#codly.new(code, width: auto)
#codly.new(code, width: 50%)
#codly.new(code, width: 100pt)
#codly.new(
  raw("a deliberately long line verifies auto width stops at the page margins", block: true),
  width: auto,
)
