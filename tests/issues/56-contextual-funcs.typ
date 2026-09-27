#import "../../codly.typ" as codly
#set page(width: 240pt, height: auto, margin: 5pt)

// An explicit palette preserves alternating rows; a scalar fills every row.
#show: codly.line-set_(fill: (luma(240), red))
#show grid: it => {
  assert.eq(range(3).map(y => (it.fill)(1, y)), (luma(240), red, luma(240)))
  it
}

#codly.new(```rs
pub fn main() {
  println!("Hello, World!");
}
```)
