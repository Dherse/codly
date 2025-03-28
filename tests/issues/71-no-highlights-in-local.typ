#import "../../codly.typ": *

#show: codly-init.with()

= This does not work

#local(
  raw("System.out.println();", lang: "java", block: true),
  highlights: (
    (line: 1, start: 1, end: 6),
  ),
)

== This works

#codly(
  highlights: (
    (line: 1, start: 1, end: 6),
  ),
)
#raw("System.out.println();", lang: "java", block: true)