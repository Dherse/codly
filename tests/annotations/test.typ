#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#let suffix(body) = {
  if type(body) == str { body } else if body.has("text") { body.text } else if body.has(
    "children",
  ) { body.children.map(suffix).join() } else { "" }
}

#let line-show(it) = {
  let fields = e.fields(it)
  let body = fields.body
  if type(body) == content and body.func() == raw.line {
    [#metadata((number: body.number, text: body.text))<annotation-line>#it]
  } else {
    it
  }
}

#set page(width: 175pt, height: auto, margin: 5pt)
#show: codly.ref-set_(sep: " / ", numbering: n => [L#n])
#show: codly.line-show_(line-show)
#show: codly.annotation-show_(it => {
  let fields = e.fields(it)
  [#metadata((
      num: fields.num,
      body: fields.body,
      height: fields.height,
      numbering: suffix((fields.numbering)(fields.num)),
    ))<annotation-seen>#it]
})
#show grid.cell: it => {
  if it.rowspan > 1 { [#metadata(it.rowspan)<annotation-rowspan>#it] } else { it }
}

// A wrapped line makes the actual row span larger than the default line
// height. The annotation must follow the first and following line bounds.
#metadata("wrapped")<wrapped-case>
#{
  set text(size: 12pt)
  show: codly.line-set_(inset: 3pt)
  codly.new(
    raw(
      "short\nthis line is deliberately long so it wraps in the narrow test page\nend",
      block: true,
    ),
    annotations: ((start: 1, end: 2, content: block(inset: 2pt)[wrapped]),),
  )
}

// A range can start inside an annotation; only displayed rows belong to it.
#metadata("ranges")<ranges-case>
#codly.new(
  raw("a\nb\nc\nd\ne\nf", block: true),
  ranges: (codly.range(4, 6),),
  annotations: ((start: 3, end: 5, content: [ranged]),),
)

// An explicit skip contributes a displayed row inside a spanning annotation.
#metadata("skips")<skips-case>
#codly.new(
  raw("a\nb\nc\nd\ne\nf", block: true),
  skips: ((3, 2),),
  annotations: ((start: 2, end: 5, content: [skipped]),),
)

// A breakable source may paginate while retaining a valid annotation element.
#metadata("paged")<paged-case>
#{
  set page(height: 78pt, margin: 5pt)
  set text(size: 11pt)
  codly.new(
    raw(range(1, 15).map(n => "line " + str(n)).join("\n"), block: true),
    breakable: true,
    annotations: ((start: 2, end: 11, content: [paged]),),
  )
}

#context {
  let lines-between(start, end) = query(
    selector(<annotation-line>).after(start.location()).before(end.location()),
  )
  let ann-between(start, end) = query(
    selector(<annotation-seen>).after(start.location()).before(end.location()),
  )
  let wrapped = lines-between(query(<wrapped-case>).first(), query(<ranges-case>).first())
  let wrapped-ann = ann-between(query(<wrapped-case>).first(), query(<ranges-case>).first()).first()
  let wrapped-after = wrapped.at(2).location().position()
  let wrapped-first = wrapped.first().location().position()
  assert.eq(wrapped.map(it => it.value.number), (1, 2, 3))
  assert.eq(wrapped-ann.location().position().page, wrapped-first.page)
  assert((wrapped-ann.location().position().y - wrapped-first.y).abs < 0.1pt)
  assert(wrapped-ann.value.height + 9pt >= wrapped-after.y - wrapped-first.y - 0.1pt)

  let ranged = lines-between(query(<ranges-case>).first(), query(<skips-case>).first())
  let ranged-ann = ann-between(query(<ranges-case>).first(), query(<skips-case>).first()).first()
  let ranged-start = ranged.filter(it => it.value.number == 4).first().location().position()
  let ranged-after = ranged.filter(it => it.value.number == 6).first().location().position()
  assert(ranged-ann.value.height + 9pt >= ranged-after.y - ranged-start.y - 0.1pt)

  let skipped = lines-between(query(<skips-case>).first(), query(<paged-case>).first())
  let skipped-ann = ann-between(query(<skips-case>).first(), query(<paged-case>).first()).first()
  let skipped-start = skipped.filter(it => it.value.number == 2).first().location().position()
  let skipped-after = skipped.filter(it => it.value.number == 8).first().location().position()
  assert(skipped-ann.value.height + 9pt >= skipped-after.y - skipped-start.y - 0.1pt)

  let paged = query(selector(<annotation-line>).after(query(<paged-case>).first().location()))
  let pages = ()
  for line in paged {
    let page = line.location().position().page
    if page not in pages { pages.push(page) }
  }
  assert(paged.len() == 14)
  assert(pages.len() > 1)
  let paged-ann = query(
    selector(<annotation-seen>).after(query(<paged-case>).first().location()),
  ).first()
  assert(paged-ann.value.height > 0pt)

  assert.eq(query(<annotation-seen>).map(it => it.value.num), (1, 1, 1, 1))
  assert.eq(query(<annotation-rowspan>).map(it => it.value), (2, 2, 5, 10))
}
