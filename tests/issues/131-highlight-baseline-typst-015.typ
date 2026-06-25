#import "../../codly.typ": *

#show: codly-init.with()

#codly(highlights: (
  (line: 3, start: 3, end: 10, fill: orange),
))
```rust
pub fn main() {
  println!("Hello, world!");
  println!("Hello, world!");
}
```
