#import "../../codly.typ" as codly

#set page(width: 300pt, height: auto, margin: 8pt)
#set text(size: 9pt)
#let code = raw("setup()\nprepare()\nload()\nprocess()\nsave()\ncleanup()", lang: "py", block: true)

#codly.new(code, range: (3, 5), header: [Default: original source numbers])
#codly.new(code, range: (3, 5), offset: auto, header: [offset: auto])
#codly.new(code, range: (3, 5), offset: 20, header: [Explicit offset: 20])
#codly.new(raw("continued()", lang: "py", block: true), offset: 7, header: [Parent block])<parent>
#codly.new(
  raw("next()\nfinish()", lang: "py", block: true),
  offset: <parent>,
  header: [offset: parent label],
)
#{
  show: codly.number-set_(placement: "outside")
  codly.new(
    code,
    ranges: ((2, 3), (5, 6)),
    offset: auto,
    smart-skip: (first: false, last: false, rest: true),
    header: [Disjoint ranges retain gaps],
  )
}
