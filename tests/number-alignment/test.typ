#import "../../codly.typ" as codly

#set page(width: 500pt, height: auto, margin: 8pt)
#set text(size: 9pt)

#let source = raw(
  "prepare()\n# Explain the next step.\n    process()\nfinish()",
  lang: "py",
  block: true,
)

#let sample(id, alignment, placement, options) = {
  show: codly.number-set_(
    numbering: "(1)",
    align: alignment,
    placement: placement,
  )
  show text: it => if (
    it.text in ("prepare", "process", "finish") or it.text.contains("Explain the next step")
  ) {
    [#metadata((id: id, source: it.text))<alignment-code>#it]
  } else if it.text == "!" {
    box[#metadata(id)<alignment-gutter>#it]
  } else { it }
  let settings = options
  if options.at("gutters", default: auto) != auto and options.gutters.len() > 0 {
    settings.gutters = (
      auto,
      (
        values: ("!", "!", "!", "!"),
        width: 28pt,
        inset: 0pt,
      ),
    )
  }
  [#metadata(id)<alignment-origin>#codly.new(
      source,
      number-enabled: false,
      unnumbered: (2,),
      ..settings,
    )]
}

// Each pair has the same source and dimensions. Number styling must not move
// any source line when the automatic number column is absent.
#let cases = (
  ("Inside", "inside", right + horizon, (:)),
  ("Outside", "outside", right + horizon, (:)),
  ("Centered numbers", "inside", center + horizon, (:)),
  ("Padding geometry", "inside", right + horizon, (padding: 8pt)),
  ("Wrap-marker geometry", "outside", right + horizon, (wrap-marker: [↪])),
  ("Indent-guide geometry", "inside", right + horizon, (indent-guides: true)),
  ("Intrinsic width", "outside", right + horizon, (width: auto)),
  ("Explicit empty gutters", "inside", right + horizon, (gutters: ())),
  ("Custom gutter", "inside", right + horizon, (gutters: (auto,))),
  ("Custom outside gutter", "outside", right + horizon, (gutters: (auto,))),
)

#for (index, (title, placement, alignment, options)) in cases.enumerate() {
  heading(level: 2, title)
  grid(
    columns: (1fr, 1fr),
    column-gutter: 16pt,
    [Left number alignment],
    [#if alignment.x == right { [Right] } else { [Center] } number alignment],

    sample((index, 0), left + horizon, placement, options),
    sample((index, 1), alignment, placement, options),
  )
}

#context {
  let origins = query(<alignment-origin>)
  let positions = query(<alignment-code>)
  for index in range(cases.len()) {
    let runs = ((), ())
    for side in (0, 1) {
      let id = (index, side)
      let origin = origins.find(mark => mark.value == id).location().position().x
      runs.at(side) = positions
        .filter(mark => mark.value.id == id)
        .map(mark => (
          mark.value.source,
          mark.location().position().x - origin,
        ))
    }
    assert.eq(runs.first().len(), 4)
    assert.eq(runs.last().len(), 4)
    for (before, after) in runs.first().zip(runs.last()) {
      assert.eq(before.first(), after.first())
      assert(
        calc.abs(before.last() - after.last()) < 0.01pt,
        message: cases.at(index).first() + ": number alignment moved source text",
      )
    }
    if index >= 8 {
      // Custom gutters retain their inherited number alignment even though
      // the automatic numbering column has been removed.
      let gutters = query(<alignment-gutter>)
      let offsets = (0, 1).map(side => {
        let id = (index, side)
        let origin = origins.find(mark => mark.value == id).location().position().x
        gutters.find(mark => mark.value == id).location().position().x - origin
      })
      assert(
        offsets.last() > offsets.first() + 10pt,
        message: cases.at(index).first() + ": gutter offsets " + repr(offsets),
      )
    }
  }
}
