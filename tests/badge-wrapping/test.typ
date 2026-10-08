#import "../../codly.typ" as codly
#import "../../src/wrap.typ" as wrap

#set page(width: 240pt, height: auto, margin: 5pt)
#show: codly.lang-set_(languages: (py: (name: "Python", color: blue)))

#let text-of(body) = {
  if body == none { "" } else if body.has("text") { body.text } else if body.has("body") {
    text-of(body.body)
  } else if body.has("child") {
    text-of(body.child)
  } else if body.has("children") { body.children.map(text-of).join() } else { "" }
}
#let source = "alpha beta gamma delta extra second"

#let sample(
  key,
  wraps: true,
  badges: ("Python",),
  hidden: false,
  first: 1,
  prefix: "",
  source-row: source,
  ..args,
) = context {
  let owner = here()
  show: codly.line-set_(fill: (luma(240), none))
  show: codly.lang-set_(display-name: not hidden, display-icon: not hidden)
  show raw.line: it => {
    set text(font: "DejaVu Sans Mono")
    [#metadata((key: key, number: it.number, text: it.text))<badge-source>#wrap.annotate(
        it.body,
        owner,
        it.number,
      )]
  }
  show box: it => context {
    let name = text-of(it.body)
    if name in ("Python", "a.py") {
      [#metadata((key: key, name: name, size: measure(it)))<badge-bounds>#it]
    } else { it }
  }
  [#text(size: 8pt, key)]
  codly.new(raw(prefix + source-row + "\n" + source-row, block: true, lang: "py"), ..args)
  context {
    let points = query(selector(<__codly-wrap-point>).after(owner).before(here())).filter(it => (
      it.value.owner == owner
    ))
    let first-points = points.filter(it => it.value.row == first)
    let second-points = points.filter(it => it.value.row == first + 1)
    let heights(items) = items.map(it => it.location().position().y).dedup()
    assert.eq(heights(first-points).len() > 1, wraps, message: key)
    assert.eq(heights(second-points).len(), 1, message: "later row lost full width: " + key)
    let shown = query(<badge-bounds>).filter(it => it.value.key == key)
    assert.eq(shown.map(it => it.value.name).sorted(), badges.sorted())
    if shown.len() == 2 {
      let a = shown.first()
      let b = shown.last()
      let ax = a.location().position().x
      let bx = b.location().position().x
      assert(ax + a.value.size.width <= bx or bx + b.value.size.width <= ax)
    }
    for badge in shown {
      let at = badge.location().position()
      let end = at.x + badge.value.size.width
      // Every wrapped fragment of the first source row stays clear of badges.
      assert(
        first-points.all(point => {
          let p = point.location().position()
          p.x <= at.x or p.x - point.value.width >= end
        }),
        message: "source overlapped badge: " + key,
      )
    }
    if key == "indented filename" {
      let cells = query(selector(<__codly-geometry>).after(owner).before(here())).filter(it => (
        it.value.kind == "cell-start" and it.value.guides.len() > 0
      ))
      assert.eq(cells.len(), 2)
      let guide-x(cell) = cell.location().position().x + cell.value.guides.first().x
      let text-x(point) = point.location().position().x - point.value.width
      assert(
        calc.abs(
          guide-x(cells.first())
            - guide-x(cells.last())
            - (text-x(first-points.first()) - text-x(second-points.first())),
        )
          < 0.001pt,
      )
    }
    let rows = query(<badge-source>).filter(it => it.value.key == key).map(it => it.value)
    assert.eq(rows.map(it => it.number), (first, first + 1))
    assert.eq(rows.map(it => it.text), (source-row, source-row))
  }
}

#sample("no badge", wraps: false, badges: (), lang-position: none)
#sample("default language")
#sample("hidden language", wraps: false, badges: (), hidden: true)
#sample("filename left", badges: ("a.py",), file: "a.py", file-position: left, lang-position: none)
#sample(
  "filename right",
  badges: ("a.py",),
  file: "a.py",
  file-position: right,
  lang-position: none,
)
#sample("both sides", badges: ("a.py", "Python"), file: "a.py", file-position: left)
#sample(
  "both right",
  badges: ("a.py", "Python"),
  file: "a.py",
  file-position: right,
  lang-position: right,
)
#sample(
  "both left",
  badges: ("a.py", "Python"),
  file: "a.py",
  file-position: left,
  lang-position: left,
)
#sample("without numbering", number-enabled: false)
#{
  show: codly.number-set_(placement: "outside", fill: none)
  sample("outside numbers")
}
#sample("native indentation", smart-indent: false)
#sample("highlighted", highlights: ((line: 1, start: 7, end: 10, fill: yellow),))
#sample("offset numbering", first: 11, offset: 10)
#sample("auto width", width: auto)
#sample(
  "first retained row",
  prefix: "omitted\n",
  first: 9,
  offset: 7,
  range: (2, 3),
  smart-skip: false,
)
#sample("annotated row", source-row: "alpha beta gamma delta extra", annotations: (
  (start: 1, end: 2, content: [Note]),
))
#sample("callout anchor", callouts: ((line: 1, pointer: 6, body: [Here]),))
#sample(
  "indented filename",
  badges: ("a.py", "Python"),
  file: "a.py",
  file-position: left,
  source-row: "    alpha beta gamma delta end",
  indent-guides: true,
  wrap-marker: [↪],
)

// Literal source inputs can use the same inline placement as raw input.
#codly.new(source + "\n" + source, file: "a.py", file-position: left, lang-position: right)


// Intrinsic width includes the badge and its gap, then caps at the container.
#context {
  let short = raw("short", block: true, lang: "py")
  let plain = measure(codly.new(short, width: auto, lang-position: none), width: 1000pt)
  let badged = measure(codly.new(short, width: auto), width: 1000pt)
  assert(badged.width >= plain.width + measure(codly.lang("py")).width)
  let narrow = measure(codly.new(raw(source, block: true, lang: "py"), width: auto), width: 120pt)
  assert(narrow.width <= 120pt)
}
