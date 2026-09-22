#import "../../codly.typ" as codly

#set page(width: 230pt, height: auto, margin: 5pt)
#let source = "    alpha bravo delta foxtt gamma hotel indii julii"
#let marker = [#metadata(none)<painted-wrap>↪]

// Equal-length words expose actual visual line starts without relying on
// internal paragraph settings or raster snapshots to infer indentation.
#for spans in (
  ((line: 1, start: 1, end: 999),),
  ((line: 1, start: 3, end: 999),), // whitespace remains atomic
  ((line: 1, start: 5, end: 999),), // begins after the source indentation
  ((line: 1, start: 1, end: 999), (line: 1, start: 5, end: 999)),
) {
  for enabled in (false, true) {
    context {
      let origin = here()
      show regex("alpha|bravo|delta|foxtt|gamma|hotel|indii|julii"): it => [#it#metadata(
          none,
        )<word-end>]
      codly.new(
        raw(source, block: true),
        highlights: spans,
        wrap-marker: if enabled { marker } else { none },
        indent-guides: true,
      )
      context {
        let words = query(selector(<word-end>).after(origin).before(here())).map(m => m
          .location()
          .position())
        assert.eq(words.len(), 8)
        let first = words.first()
        let starts = words
          .enumerate()
          .filter(((i, at)) => i > 0 and at.y > words.at(i - 1).y + 1pt)
          .map(((i, at)) => at)
        assert(starts.len() > 0)
        let rows = query(selector(<__codly-wrap-row>).after(origin).before(here()))
        let advance = if enabled { rows.first().value.advance } else { 0pt }
        for at in starts {
          assert(calc.abs(at.x - first.x - advance) < 0.01pt, message: repr((
            spans,
            enabled,
            first.x,
            at.x,
            advance,
          )))
        }
        let arrows = query(selector(<painted-wrap>).after(origin).before(here()))
        assert.eq(arrows.len(), if enabled { starts.len() } else { 0 })
      }
    }
  }
}

// Disabling smart-indent still allows a highlight to wrap, without retaining
// the original indentation or painting the configured continuation marker.
#context {
  let origin = here()
  show regex("alpha|bravo|delta|foxtt|gamma|hotel|indii|julii"): it => [#it#metadata(
      none,
    )<word-end>]
  codly.new(
    raw(source, block: true),
    highlights: ((line: 1, start: 1, end: 999),),
    smart-indent: false,
    wrap-marker: marker,
  )
  context {
    let words = query(selector(<word-end>).after(origin).before(here())).map(m => m
      .location()
      .position())
    let next = words.find(at => at.y > words.first().y + 1pt)
    assert(next != none and next.x < words.first().x - 10pt)
    assert.eq(query(selector(<painted-wrap>).after(origin).before(here())).len(), 0)
  }
}
