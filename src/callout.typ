// Pointed callouts: source anchors, native text layout, and one painted outline.
#import "@preview/elembic:1.1.1" as e

#let bubble-name(name) = if name.starts-with("bubble-") { name.slice(7) } else { name }
#let style-names = (
  "bubble-gap",
  "pointer-align",
  "pointer-size",
  "pointer-height",
  "pointer-width",
  "pointer-offset",
  "bubble-align",
  "bubble-fill",
  "bubble-stroke",
  "bubble-inset",
  "bubble-outset",
  "bubble-radius",
  "bubble-width",
)

// One schema owns both the bubble's defaults and callout-level overrides.
#let fields(entry: false, bubble: false) = {
  let field(name, ty, default, doc) = {
    let styling = name in style-names
    if bubble and not styling { return none }
    let inherit = entry or (not bubble and styling)
    e.field(
      if bubble { bubble-name(name) } else { name },
      if inherit { e.types.union(ty, auto) } else { ty },
      default: if inherit { auto } else { default },
      doc: doc,
      folds: false,
    )
  }
  (
    field(
      "placement",
      e.types.union("above", "below"),
      "below",
      "Side of the source line on which to place the callout.",
    ),
    field(
      "bubble-gap",
      e.types.union(length, dictionary),
      0.5em,
      "Minimum separation: a length for both axes, or (x: length, y: length). Omitted axes default to 0.5em.",
    ),
    field(
      "pointer",
      e.types.option(int),
      none,
      "Character in the attached source line (one-based, like highlights; 0 means line start). `none` disables the bubble.",
    ),
    field(
      "pointer-align",
      e.types.union("start", "center", "end"),
      "center",
      "Preferred bubble alignment about the source character, clamped to the available row.",
    ),
    field("pointer-size", length, 0.4em, "Height and half-base width of the arrow."),
    field(
      "pointer-height",
      e.types.union(length, auto),
      auto,
      "Arrow height; auto uses pointer-size.",
    ),
    field(
      "pointer-width",
      e.types.union(length, auto),
      auto,
      "Full arrow base width; auto uses twice pointer-size.",
    ),
    field(
      "pointer-offset",
      length,
      0pt,
      "Horizontal shift from the source character; positive points right, negative left. Clamped to the bubble.",
    ),
    field(
      "bubble-align",
      alignment,
      center,
      "Alignment of the content inside the bubble, independent of cell alignment.",
    ),
    field(
      "bubble-fill",
      e.types.option(e.types.paint),
      luma(245),
      "Fill of the entire bubble and arrow.",
    ),
    field(
      "bubble-stroke",
      e.types.option(stroke),
      0.6pt + luma(80),
      "Stroke of the single bubble outline.",
    ),
    field(
      "bubble-inset",
      e.types.union(length, dictionary),
      (x: 0.5em, y: 0.3em),
      "Padding inside the bubble.",
    ),
    field(
      "bubble-outset",
      e.types.union(length, dictionary),
      0pt,
      "Extra paint extent around the padded body; reserved in the row.",
    ),
    field("bubble-radius", length, 2pt, "Corner radius of the bubble."),
    field(
      "bubble-width",
      e.types.union(length, ratio, auto),
      auto,
      "Preferred padded body width; auto fits the content, bounded by the row.",
    ),
  ).filter(f => f != none)
}

#let resolve(value, defaults, bubble-defaults: none) = {
  let result = (:)
  for name in ("placement", "pointer", ..style-names) {
    let local = value.at(name)
    let chosen = if local == auto { defaults.at(name) } else { local }
    if chosen == auto and bubble-defaults != none and name in style-names {
      chosen = bubble-defaults.at(bubble-name(name))
    }
    result.insert(name, chosen)
  }
  result
}

// Only mark requested characters. The markers occupy no width and survive
// syntax styles, highlights, native line breaks, and smart indentation.
#let annotate(body, data) = {
  let visit(body, offset) = {
    if body.has("label") and body.label == <codly-highlight> { return (body, offset) }
    if body.has("text") {
      let result = ()
      let part = ""
      for c in body.text.clusters() {
        let before = offset
        offset += c.len()
        part += c
        let targets = data.pointers.filter(p => before < p and p <= offset)
        if targets.len() > 0 {
          result.push(text(part))
          part = ""
          for pointer in targets {
            result.push(context [#metadata((
              owner: data.owner,
              row: data.row,
              pointer: pointer,
              advance: measure(text(c)).width / 2,
            ))<__codly-callout-anchor>])
          }
        }
      }
      result.push(text(part))
      (result.join(), offset)
    } else if body.has("children") {
      let result = ()
      for child in body.children {
        let (child, end) = visit(child, offset)
        result.push(child)
        offset = end
      }
      (result.join(), offset)
    } else if body.has("child") and body.has("styles") {
      let (child, end) = visit(body.child, offset)
      ((body.func())(child, body.styles), end)
    } else if body.has("body") {
      let args = body.fields()
      let (child, end) = visit(args.body, offset)
      args.body = child
      ((body.func())(..args), end)
    } else { (body, offset) }
  }
  let start = if 0 in data.pointers {
    [#metadata((
      owner: data.owner,
      row: data.row,
      pointer: 0,
      advance: 0pt,
    ))<__codly-callout-anchor>]
  } else { [] }
  start + visit(body, 0).first()
}

#let sides(value) = {
  let d = if type(value) == dictionary { value } else { (rest: value) }
  let rest = d.at("rest", default: 0pt)
  let side(name, axis) = d.at(name, default: d.at(axis, default: rest)).to-absolute()
  (
    left: side("left", "x"),
    right: side("right", "x"),
    top: side("top", "y"),
    bottom: side("bottom", "y"),
  )
}

// A single closed path avoids seams and shares one gradient/tiling coordinate
// system across the arrow and rounded rectangle.
#let outline(w, h, arrow, tip, radius, fill, stroke, arrow-width: auto, above: false) = {
  let r = calc.min(radius, w / 2, (h - arrow) / 2)
  let k = r * 0.5522847498
  let half = calc.min(if arrow-width == auto { arrow } else { arrow-width / 2 }, (w - 2 * r) / 2)
  let base = calc.min(w - r - half, calc.max(r + half, tip))
  let point(x, y) = (x, if above { h - y } else { y })
  curve(
    fill: fill,
    stroke: stroke,
    curve.move(point(r, arrow)),
    curve.line(point(base - half, arrow)),
    curve.line(point(tip, 0pt)),
    curve.line(point(base + half, arrow)),
    curve.line(point(w - r, arrow)),
    curve.cubic(point(w - r + k, arrow), point(w, arrow + r - k), point(w, arrow + r)),
    curve.line(point(w, h - r)),
    curve.cubic(point(w, h - r + k), point(w - r + k, h), point(w - r, h)),
    curve.line(point(r, h)),
    curve.cubic(point(r - k, h), point(0pt, h - r + k), point(0pt, h - r)),
    curve.line(point(0pt, arrow + r)),
    curve.cubic(point(0pt, arrow + r - k), point(r - k, arrow), point(r, arrow)),
    curve.close(),
  )
}

// Measure once at the full available row width, letting Typst wrap the body.
#let geometry(it, row-width, origin) = {
  assert(
    it.__anchor != none,
    message: "codly: pointed callouts need a source line; use the block's `callouts` field",
  )
  let anchor = query(<__codly-callout-anchor>).find(m => (
    m.value.owner == it.__anchor.owner and m.value.row == it.line and m.value.pointer == it.pointer
  ))
  let target = if anchor == none { 0pt } else {
    anchor.location().position().x - anchor.value.advance - origin.x
  }
  let inset = sides(it.at("bubble-inset"))
  let outset = sides(it.at("bubble-outset"))
  assert(
    (..inset.values(), ..outset.values()).all(v => v >= 0pt),
    message: "codly: bubble inset and outset must be non-negative",
  )
  let size = it.at("pointer-size").to-absolute()
  let arrow = it.at("pointer-height")
  let arrow = if arrow == auto { size } else { arrow.to-absolute() }
  let arrow-width = it.at("pointer-width")
  let arrow-width = if arrow-width == auto { 2 * size } else { arrow-width.to-absolute() }
  let radius = it.at("bubble-radius").to-absolute()
  assert(
    size >= 0pt and radius >= 0pt,
    message: "codly: pointer size and bubble radius must be non-negative",
  )
  assert(
    arrow >= 0pt and arrow-width >= 0pt,
    message: "codly: pointer height and width must be non-negative",
  )
  let stroke = it.at("bubble-stroke")
  let edge = if stroke == none { 0pt } else if stroke.thickness == auto { 0.5pt } else {
    stroke.thickness.to-absolute() / 2
  }
  let available = calc.max(0pt, row-width - 2 * edge)
  // Fit even deliberately oversized decorations into a narrow row.
  let decorations = inset.left + inset.right + outset.left + outset.right
  if decorations > available and decorations > 0pt {
    let scale = available / decorations
    inset.left *= scale
    inset.right *= scale
    outset.left *= scale
    outset.right *= scale
  }
  let horizontal = inset.left + inset.right
  let outer = outset.left + outset.right
  let natural = measure(it.body).width + horizontal
  let requested = it.at("bubble-width")
  let requested = if requested == auto { natural } else if type(requested) == ratio {
    row-width * requested
  } else { requested.to-absolute() }
  assert(requested >= 0pt, message: "codly: bubble width must be non-negative")
  let width = calc.min(calc.max(horizontal, requested), calc.max(0pt, available - outer))
  let body = block(width: width, inset: inset, above: 0pt, below: 0pt, breakable: false, align(
    it.at("bubble-align"),
    it.body,
  ))
  let body-height = measure(body).height
  let w = width + outer
  let h = body-height + outset.top + outset.bottom + arrow
  let desired = (
    target
      - if it.at("pointer-align") == "start" { 0pt } else if it.at("pointer-align") == "end" {
        w
      } else { w / 2 }
  )
  let x = calc.min(calc.max(edge, desired), calc.max(edge, row-width - edge - w))
  let tip = calc.min(w, calc.max(0pt, target + it.at("pointer-offset").to-absolute() - x))
  (
    x: x,
    w: w,
    h: h,
    edge: edge,
    arrow: arrow,
    arrow-width: arrow-width,
    tip: tip,
    radius: radius,
    outset: outset,
    body: body,
  )
}

#let paint(it, g) = {
  let above = it.placement == "above"
  block(
    width: g.w + 2 * g.edge,
    height: g.h + 2 * g.edge,
    above: 0pt,
    below: 0pt,
    breakable: false,
  )[
    #place(top + left, dx: g.edge, dy: g.edge, outline(
      g.w,
      g.h,
      g.arrow,
      g.tip,
      g.radius,
      it.at("bubble-fill"),
      it.at("bubble-stroke"),
      arrow-width: g.arrow-width,
      above: above,
    ))
    #place(
      top + left,
      dx: g.edge + g.outset.left,
      dy: g.edge + g.outset.top + if above { 0pt } else { g.arrow },
      g.body,
    )
  ]
}

#let render(it) = {
  if it.pointer == none { return it.body }
  if it.__layout != none { return paint(it, it.__layout) }
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, layout(size => {
    let g = geometry(it, size.width, here().position())
    block(width: size.width, height: g.h + 2 * g.edge, above: 0pt, below: 0pt, breakable: false)[
      #place(top + left, dx: g.x - g.edge, paint(it, g))
    ]
  }))
}

// The bubble is a real sub-element, so show rules can observe each painted
// instance. Callout cell styles never leak into its fill, padding or alignment.
#let bubble-display(it) = {
  let row = (
    body: it.body,
    line: it.line,
    pointer: it.pointer,
    placement: it.placement,
    __anchor: it.__anchor,
    __layout: it.__layout,
  )
  for name in style-names { row.insert(name, it.at(bubble-name(name))) }
  render(row)
}

#let display(bubble, it) = {
  if it.pointer == none { return it.body }
  e.get(get => {
    let settings = resolve(it, it, bubble-defaults: get(bubble))
    let args = (:)
    for name in style-names { args.insert(bubble-name(name), settings.at(name)) }
    bubble(
      it.body,
      line: it.line,
      pointer: it.pointer,
      placement: it.placement,
      __anchor: it.__anchor,
      __layout: it.__layout,
      ..args,
    )
  })
}

#let pack(rows, constructor) = block(
  width: 100%,
  above: 0pt,
  below: 0pt,
  breakable: false,
  layout(size => {
    let origin = here().position()
    let lanes = ()
    for row in rows {
      let g = geometry(row, size.width, origin)
      let gap = row.at("bubble-gap")
      let gap = if type(gap) == dictionary { gap } else { (x: gap, y: gap) }
      assert(
        gap.keys().all(k => k in ("x", "y")),
        message: "codly: bubble gap accepts only x and y",
      )
      let spacing = gap.at("x", default: 0.5em)
      let vertical = gap.at("y", default: 0.5em)
      assert(
        type(spacing) == length and type(vertical) == length,
        message: "codly: bubble gap axes must be lengths",
      )
      let spacing = spacing.to-absolute()
      let vertical = vertical.to-absolute()
      assert(spacing >= 0pt and vertical >= 0pt, message: "codly: bubble gap must be non-negative")
      let a = g.x - g.edge
      let b = g.x + g.w + g.edge
      let overlap = (
        lanes.len() == 0
          or lanes
            .last()
            .items
            .any(item => (
              a < item.right + calc.max(spacing, item.gap)
                and b + calc.max(spacing, item.gap) > item.left
            ))
      )
      if overlap { lanes.push((items: (), height: 0pt, gap: 0pt)) }
      lanes.last().items.push((row: row, geometry: g, left: a, right: b, gap: spacing))
      lanes.last().height = calc.max(lanes.last().height, g.h + 2 * g.edge)
      lanes.last().gap = calc.max(lanes.last().gap, vertical)
    }
    let gaps = lanes.zip(lanes.slice(1)).map(((a, b)) => calc.max(a.gap, b.gap))
    let height = lanes.map(l => l.height).sum() + gaps.fold(0pt, (a, b) => a + b)
    block(width: size.width, height: height, above: 0pt, below: 0pt, breakable: false, {
      let y = 0pt
      for (index, lane) in lanes.enumerate() {
        if index > 0 { y += gaps.at(index - 1) }
        for item in lane.items {
          let row = item.row
          let body = row.remove("body")
          let dy = if row.placement == "above" {
            lane.height - item.geometry.h - 2 * item.geometry.edge
          } else { 0pt }
          place(top + left, dx: item.left, dy: y + dy, constructor(
            body,
            ..row,
            __layout: item.geometry,
          ))
        }
        y += lane.height
      }
    })
  }),
)

// Consecutive bubbles with identical cell styling can share a grid cell.
// Plain rows or different cell styles form a boundary, preserving their fills
// and spacing. Within a group, collision lanes retain declaration order.
#let row-cells(entries, constructor, defaults, owner, source-line, colspan) = {
  let groups = ()
  for entry in entries {
    let settings = resolve(entry, defaults)
    for name in ("align", "breakable", "fill", "inset", "stroke") {
      let value = entry.at(name)
      settings.insert(name, if value == auto { defaults.at(name) } else { value })
    }
    let cell = (:)
    for name in ("align", "breakable", "fill", "inset", "stroke") {
      if settings.at(name) != auto { cell.insert(name, settings.at(name)) }
    }
    if settings.pointer != none { cell.insert("breakable", false) }
    let row = (body: entry.body, line: source-line, __anchor: (owner: owner), ..settings)
    if (
      settings.pointer != none
        and groups.len() > 0
        and groups.last().bubbles
        and groups.last().cell == cell
    ) {
      groups.last().rows.push(row)
    } else {
      groups.push((rows: (row,), bubbles: settings.pointer != none, cell: cell))
    }
  }
  groups.map(group => {
    let body = if not group.bubbles {
      let row = group.rows.first()
      let body = row.remove("body")
      constructor(body, ..row)
    } else { pack(group.rows, constructor) }
    grid.cell(body, colspan: colspan, ..group.cell)
  })
}
