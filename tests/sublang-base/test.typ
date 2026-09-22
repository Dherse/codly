#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 300pt, height: auto, margin: 5pt)

#codly.new(
  ````markdown
  # Header

  This is a sub-block in another language, highlighted correctly:
  ```rs
  fn main() {
      println!("Hello, world!");
  }
  ```
  ````,
)

#codly.new(
  ````sh
  cat main.rs
  fn main() {
      println!("Hello, world!");
  }

  cat main.c
  #include <stdio.h>
  int main() {
      printf("Hello, world!\n");
      return 0;
  }
  ````,
  sublangs: (
    (start: 2, end: 4, lang: "rs"),
    (start: 6, end: 10, lang: "c"),
  ),
  highlights: (
    (line: 3, start: 5, end: 12, tag: "rs-macro"),
    (line: 9, start: 5, end: 10, tag: "c-func"),
  ),
)
