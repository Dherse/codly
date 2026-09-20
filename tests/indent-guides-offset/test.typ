#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 260pt, height: auto, margin: 5pt)
#assert.eq(e.fields(codly.indent-guides()).x-offset, 0pt)
#assert.eq(e.fields(codly.indent-guides(x-offset: -0.5em)).x-offset, -0.5em)
#assert(catch(() => codly.indent-guides(x-offset: "right")) != none)
#assert(catch(() => codly.indent-guides(x-offset: 10%)) != none)

// Check the actual painted positions and source positions at two font sizes,
// with inside/outside/disabled numbers. Rainbow preparation must retain offsets.
#for size in (10pt, 16pt) {
  set text(size: size)
  for (numbers, outside) in ((true, false), (true, true), (false, false)) {
    context {
      let origin = here()
      for shift in (0pt, 2pt, -2pt, 0.5em, -0.25em) {
        show: e.set_(codly.codly-number, placement: if outside { "outside" } else { "inside" })
        show: codly.line-show_(it => [#metadata(shift)<offset-row>#it])
        show line: it => context {
          [#metadata((
              shift: shift.to-absolute(),
              color: it.stroke.paint,
              height: it.end.last(),
            ))<offset-stroke>#it]
        }
        codly.new(
          raw(
            "root {\n    child {\n        call(long_argument, another_long_argument);\n    }\n}",
            lang: "js",
            block: true,
          ),
          number-enabled: numbers,
          rainbow: (palette: (red, blue)),
          indent-guides: (width: 4, x-offset: shift),
        )
      }
      context {
        let strokes = query(selector(<offset-stroke>).after(origin).before(here()))
        let rows = query(selector(<offset-row>).after(origin).before(here()))
        assert.eq(strokes.len(), 20)
        assert.eq(rows.len(), 25)
        let baseline = strokes.slice(0, 4)
        let base-rows = rows.slice(0, 5)
        for variant in range(1, 5) {
          let moved = strokes.slice(variant * 4, (variant + 1) * 4)
          for (a, b) in baseline.zip(moved) {
            let delta = b.location().position().x - a.location().position().x
            assert(calc.abs(delta - b.value.shift) < 0.001pt)
            assert.eq(a.value.color, b.value.color)
            assert(calc.abs((a.value.height - b.value.height).length) < 0.001pt)
          }
          let moved-rows = rows.slice(variant * 5, (variant + 1) * 5)
          let dy = (
            moved-rows.first().location().position().y - base-rows.first().location().position().y
          )
          for (a, b) in base-rows.zip(moved-rows) {
            assert.eq(a.location().position().x, b.location().position().x)
            assert(calc.abs(b.location().position().y - a.location().position().y - dy) < 0.001pt)
          }
        }
      }
    }
  }
}

// Extreme offsets must not paint into line numbers or annotation cells.
#context {
  let origin = here()
  show line: it => [#metadata(none)<clipped-guide>#it]
  for shift in (-1000pt, 1000pt) {
    codly.new(
      raw("root\n    child", block: true),
      annotations: ((start: 2, content: [note]),),
      indent-guides: (x-offset: shift),
    )
  }
  context {
    assert.eq(query(selector(<clipped-guide>).after(origin).before(here())).len(), 0)
  }
}
