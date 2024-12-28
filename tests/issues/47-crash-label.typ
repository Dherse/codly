
#import "../../codly.typ": *
#show: codly-init.with()

#set page(height: auto, margin: 5pt, width: 250pt)

#codly(highlights: ((line: 2, start: 3, label: <hello>), ))
```rs
pub fn main() {
  println!("Hello, World!");
}
```