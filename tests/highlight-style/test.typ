#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)
#show: codly.highlight-set_(
  color: red,
  fill: color => color,
  stroke: color => color + 1pt,
  clip: false,
)

#let check(expected, body) = {
  show box: it => {
    if it.body == [word] {
      let baseline = it.baseline.at("shift", default: auto)
      assert.eq((it.fill, it.stroke, it.clip, baseline), expected)
      [#metadata(none)<styled-highlight>]
    }
    it
  }
  body
}

#check((red, red + 1pt, false, 0pt), codly.codly-highlight([word]))
#check((blue, green + 2pt, true, 3pt), codly.codly-highlight([word], highlight: (
  line: 1,
  fill: blue,
  stroke: green + 2pt,
  clip: true,
  baseline: 3pt,
)))
#check((blue, blue + 1pt, false, 0pt), codly.codly-highlight([word], highlight: (
  line: 1,
  fill: color => {
    assert.eq(color, red)
    blue
  },
)))

#{
  show: codly.highlight-set_(fill: none, stroke: none)
  check((none, none, false, 0pt), codly.codly-highlight([word]))
}

#context assert.eq(query(<styled-highlight>).len(), 4)
