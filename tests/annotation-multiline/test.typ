#import "../../codly.typ" as codly

#set page(width: 300pt, height: auto, margin: 10pt)

#for numbered in (true, false) {
  codly.new(
    raw("prepare()\nresult = compute()\nprint(result)\ncleanup()", lang: "py", block: true),
    annotations: (
      (
        start: 2,
        end: 4,
        content: [Computes and displays\ the result],
        numbering: if numbered { n => [(#n)] } else { none },
      ),
    ),
  )
  parbreak()
}

