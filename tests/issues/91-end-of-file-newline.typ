#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)
#show: codly.line-set_(
  stroke: 2pt + red,
)
#show: codly.number-set_(placement: "outside", fill: none)

#codly.new(
  raw(read("./91-end-of-file-newline.txt"), block: true),
)

#codly.new(
  raw(read("./91-end-of-file-newline.txt").trim("\n"), block: true),
)

#show: codly.number-set_(placement: "inside", fill: auto)

#codly.new(
  raw(read("./91-end-of-file-newline.txt"), block: true),
)

#codly.new(
  raw(read("./91-end-of-file-newline.txt").trim("\n"), block: true),
)
