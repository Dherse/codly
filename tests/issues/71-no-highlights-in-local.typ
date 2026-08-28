#import "../../codly.typ" as codly

= This does not work

#{
  show: codly.set_(highlights: ((line: 1, start: 1, end: 6),))
  codly.new(raw("System.out.println();", lang: "java", block: true))
}

== This works

#codly.new(
  highlights: ((line: 1, start: 1, end: 6),),
  raw("System.out.println();", lang: "java", block: true),
)
