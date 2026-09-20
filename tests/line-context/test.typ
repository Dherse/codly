#import "../../codly.typ" as codly

// A line's minimum height survives glyph-specific text rules and whitespace.
// Assertions check the invisible struts without rendering the probe blocks.
#context {
  let reference = measure(width: 160pt, codly.new(
    raw("1", block: true),
    number-enabled: false,
    skip-last-empty: false,
  )).height
  for smart-indent in (false, true) {
    for source in (" ", "  ", "\t", "lowercase", "{}", "  lowercase") {
      let body = {
        show regex("[a-z{}]+"): set text(size: 3pt)
        codly.new(
          raw(source, block: true),
          number-enabled: false,
          skip-last-empty: false,
          smart-indent: smart-indent,
        )
      }
      assert.eq(
        measure(width: 160pt, body).height,
        reference,
        message: "minimum code row height changed for " + repr(source),
      )
    }
  }
}

// Metrics must be resolved after a line show rule changes the text settings.
// Moving the renderer out of its context would measure the wrong font size.
#context {
  let source = raw.line(1, 1, "    lowercase", [    lowercase])
  for size in (3pt, 19pt) {
    for highlights in (none, ((line: 1, start: 5, end: 14),)) {
      let expected = {
        set text(size: size, font: "Libertinus Serif", top-edge: "bounds", bottom-edge: "bounds")
        codly.codly-line(source, highlights: highlights)
      }
      let actual = {
        show: codly.line-show_(it => text(
          size: size,
          font: "Libertinus Serif",
          top-edge: "bounds",
          bottom-edge: "bounds",
          it,
        ))
        codly.codly-line(source, highlights: highlights)
      }
      assert.eq(measure(width: 70pt, actual), measure(width: 70pt, expected))
    }
  }
}
