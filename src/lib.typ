#import "@preview/elembic:1.1.1" as e
#import "geometry.typ" as geometry
#import "rainbow.typ" as rainbow
#import "indent.typ" as indent
#import "wrap.typ" as wrap

/// The prefix identifying codly's custom elements and types.
#let __codly-prefix = "@preview/codly:v2.0.0"
#let __codly-whitespace = regex("\\s")

/// Metadata for each codly argument, read from `src/args.json`.
/// The `doc` of each field below is the argument's `title` in that file.
#let __codly-args = json("args.json")

/// Returns the documentation title of the argument with the given name.
#let __doc(name) = {
  if name not in __codly-args {
    panic("codly: missing argument definition for: " + name)
  }
  __codly-args.at(name).title
}

/// Returns the default value of the argument with the given name, evaluated
/// from its string representation in `src/args.json`.
#let __default(name) = {
  if name not in __codly-args {
    panic("codly: missing argument definition for: " + name)
  }

  eval(__codly-args.at(name).default, mode: "code")
}

/// Read the compact block record without querying reference figures.
#let __codly-block-info(target) = {
  let origin = query(target)
  assert(origin.len() == 1, message: "codly: expected a unique code block label: " + str(target))
  let blocks = query(selector(<__codly-block>).after(origin.first().location()))
  assert(blocks.len() > 0, message: "codly: no code block found after " + str(target))
  blocks.first().value
}

#let __codly-inset(inset) = {
  if type(inset) == dictionary {
    let other = inset.at("rest", default: 0.32em)
    (
      top: inset.at("top", default: inset.at("y", default: other)),
      right: inset.at("right", default: inset.at("x", default: other)),
      bottom: inset.at("bottom", default: inset.at("y", default: other)),
      left: inset.at("left", default: inset.at("x", default: other)),
    )
  } else {
    (top: inset, right: inset, bottom: inset, left: inset)
  }
}

#let __codly-cell-args(align, breakable, fill, inset, stroke) = {
  let args = (:)
  if align != auto { args.insert("align", align) }
  if breakable != auto { args.insert("breakable", breakable) }
  if fill != auto { args.insert("fill", fill) }
  if inset != auto { args.insert("inset", inset) }
  if stroke != auto { args.insert("stroke", stroke) }
  args
}

/// Sort and merge ranges once, then advance through them alongside the lines.
#let __codly-ranges(ranges) = {
  let ordered = ()
  for r in ranges { ordered.push((r.start, if r.end == none { calc.inf } else { r.end })) }
  let merged = ()
  for (start, end) in ordered.sorted() {
    if merged.len() > 0 and start <= merged.last().last() + 1 {
      merged.last().at(1) = calc.max(merged.last().last(), end)
    } else {
      merged.push((start, end))
    }
  }
  merged
}

#let __codly-lang-show(
  it,
) = {
  // The body is the language key as a string, e.g. "py".
  let lang-key = it.body

  // Look up the language definition, if there is one.
  let lang-def = if it.languages != none {
    it.languages.at(lang-key, default: none)
  } else {
    none
  }

  let style = (:)
  for name in ("display-name", "display-icon", "fill", "stroke", "inset", "radius") {
    style.insert(name, if lang-def != none and name in lang-def { lang-def.at(name) } else {
      it.at(name)
    })
  }

  let name = if not style.display-name {
    []
  } else if lang-def != none and lang-def.name != none {
    lang-def.name
  } else if lang-def != none {
    []
  } else {
    lang-key
  }
  let icon = if style.display-icon and lang-def != none and lang-def.icon != none {
    lang-def.icon
  } else {
    []
  }
  let color = if lang-def != none and lang-def.color != none {
    lang-def.color
  } else {
    it.default-color
  }

  let lang = (name: name, icon: icon, color: color)
  let fill = style.fill
  let fill = if type(fill) == function {
    fill(lang)
  } else if fill != none {
    fill
  } else {
    color
  }

  let stroke = style.stroke
  let stroke = if type(stroke) == function {
    stroke(lang)
  } else {
    stroke
  }

  let sep = if icon != [] and name != [] {
    h(0.2em)
  } else {
    []
  }
  let body = icon + sep + name
  if body == [] {
    return []
  }

  let padding = __codly-inset(style.inset)
  let b = measure(body)
  let badge = box(
    radius: style.radius,
    fill: fill,
    inset: padding,
    stroke: stroke,
    outset: 0pt,
    height: b.height + padding.top + padding.bottom,
    body,
  )

  return badge
}

/// Trims leading whitespace-only children from content, used for references.
#let __codly-trim(body) = {
  if type(body) == str {
    return body.trim()
  }

  if body.has("children") {
    let out = ()
    let start = true
    for child in body.children {
      if start and child.has("text") and child.text.trim().len() == 0 {
        continue
      } else if start and child == [ ] {
        continue
      }

      start = false
      out.push(child)
    }

    (body.func())(out)
  } else {
    body
  }
}

// Native figure targets emit these small elements instead of formatting their
// reference bodies inline. The shared settings remain compatible with ref-set_.
#let __codly-line-ref-show(codly-ref, it) = e.get(get => {
  let shared = get(codly-ref)
  let separator = if it.separator == auto { shared.sep } else { it.separator }
  let numbering = if it.numbering == auto { shared.numbering } else { it.numbering }
  [#ref(it.block)#separator#numbering(it.number)#if it.suffix != none { it.suffix }]
})

#let __codly-highlight-ref-show(codly-ref, it) = e.get(get => {
  let shared = get(codly-ref)
  let separator = if it.separator == auto { shared.sep } else { it.separator }
  let numbering = if it.numbering == auto { shared.numbering } else { it.numbering }
  let body = if it.by == "line" {
    numbering(it.line)
  } else {
    assert(it.item != none, message: "codly: tag is required for item reference")
    it.item
  }
  [#ref(it.block)#separator#__codly-trim(body)]
})

#let __codly-annotation-ref-show(codly-ref, it) = e.get(get => {
  let shared = get(codly-ref)
  let separator = if it.separator == auto { shared.sep } else { it.separator }
  let numbering = if it.numbering == auto { shared.numbering } else { it.numbering }
  let body = if it.by == "line" {
    numbering(it.line) + if it.suffix == none { [] } else { it.suffix }
  } else {
    it.item
  }
  [#ref(it.block)#separator#__codly-trim(body)]
})

/// Cache nesting and boundary events by geometry, independently of line styles.
#let __codly-highlight-layout(spans) = {
  let keys = ()
  for (start, end) in spans {
    let depth = 0
    for (other-start, other-end) in spans {
      if other-start <= start and other-end >= end and (other-start != start or other-end != end) {
        depth += 1
      }
    }
    keys.push((-depth, start, end, keys.len()))
  }
  let order = keys.sorted()
  let boundaries = ()
  let pending = ()
  for (_, start, end, _) in order {
    boundaries.push(start)
    boundaries.push(end)
    pending.push((start, pending.len()))
  }
  (order: order, boundaries: boundaries.sorted(), pending: pending.sorted())
}

/// The length in characters of a piece of content, where content labeled
/// `<codly-highlight>` (a tagged highlight) occupies no positions.
#let __codly-line-length(child) = {
  if child.has("label") and child.label == <codly-highlight> {
    0
  } else if child.has("text") {
    child.text.len()
  } else if child.has("children") {
    let length = 0
    for child in child.children {
      length += __codly-line-length(child)
    }
    length
  } else if child.has("child") {
    __codly-line-length(child.child)
  } else if child.has("body") {
    __codly-line-length(child.body)
  } else {
    0
  }
}

/// Splits text near highlight boundaries, keeping whitespace and graphemes whole.
#let __codly-line-body(elem, boundaries, offset: 0) = {
  if elem.has("label") and elem.label == <codly-highlight> {
    (elem,)
  } else if elem.has("children") {
    let children = ()
    for child in elem.children {
      children += __codly-line-body(child, boundaries, offset: offset)
      offset += __codly-line-length(child)
    }
    children
  } else if elem.has("child") and elem.has("styles") {
    let children = __codly-line-body(elem.child, boundaries, offset: offset)
    for index in range(children.len()) {
      children.at(index) = (elem.func())(children.at(index), elem.styles)
    }
    children
  } else if elem.has("text") {
    let next = 0
    while next < boundaries.len() and boundaries.at(next) < offset { next += 1 }
    if next == boundaries.len() or boundaries.at(next) > offset + elem.text.len() {
      return (elem,)
    }
    let out = ()
    let part = ""
    let token = ""
    let was-space = false
    let clusters = elem.text.clusters()
    clusters.push("")
    for cluster in clusters {
      let is-space = cluster.contains(__codly-whitespace)
      if token != "" and (not is-space or not was-space) {
        offset += token.len()
        if next < boundaries.len() and boundaries.at(next) <= offset {
          if part != "" {
            out.push(text(part))
            part = ""
          }
          out.push(text(token))
          while next < boundaries.len() and boundaries.at(next) <= offset { next += 1 }
        } else {
          part += token
        }
        token = ""
      }
      token += cluster
      was-space = is-space
    }
    if part != "" { out.push(text(part)) }
    out
  } else {
    (elem,)
  }
}

/// Renders a single highlighted span of a code line. All styling is resolved
/// from the per-highlight overrides in the metadata record, falling back to
/// the element's own fields, and references use the `codly-ref` settings.
#let __codly-highlight-show(
  codly-ref,
  codly-highlight-ref,
  it,
) = {
  let hl = it.highlight
  let body = it.body
  if it.__continuation-indent != none {
    body = par(hanging-indent: it.__continuation-indent, body)
  }

  let base = if hl != none and hl.fill != none { hl.fill } else { it.color }
  if type(base) == function { base = base(it.color) }
  let style = (:)
  for name in ("radius", "clip", "inset", "outset", "baseline") {
    style.insert(name, if hl != none and hl.at(name) != none { hl.at(name) } else { it.at(name) })
  }
  let fill = if it.fill != none { (it.fill)(base) }
  let stroke = if hl != none and hl.stroke != none { hl.stroke } else { it.stroke }
  if type(stroke) == function { stroke = stroke(base) }

  // Build the hidden reference figure if the highlight is labeled.
  let label = if hl != none and hl.label != none {
    e.get(get => {
      assert(
        hl.at("block-label", default: none) != none,
        message: "codly: for labels on highlights to work, you must have the code block contained within a figure and that figure must have a label.",
      )
      let ref-set = get(codly-ref)
      if ref-set.by == "item" {
        assert(hl.tag != none, message: "codly: tag is required for item reference")
      }

      let block-label = hl.at("block-label")
      place(hide(pdf.artifact[#figure(
          kind: "codly-referencer",
          supplement: none,
          numbering: (..) => codly-highlight-ref(
            [],
            block: block-label,
            line: hl.at("line-number"),
            item: hl.tag,
            by: ref-set.by,
          ),
          [],
        )#hl.label]))
    })
  }

  let tag = if hl != none { hl.tag } else { none }
  if tag == none {
    box(
      radius: style.radius,
      clip: style.clip,
      fill: fill,
      stroke: stroke,
      inset: style.inset,
      outset: style.outset,
      baseline: style.baseline,
      body + label,
    )
  } else {
    // Explicit widths prevent reflow at the weak break between body and tag.
    let inset-sep = __codly-inset(style.inset)
    let size-body = measure(body)
    let size-tag = measure(tag)
    let max-height = (
      calc.max(
        size-body.height,
        size-tag.height,
      )
        + inset-sep.top
        + inset-sep.bottom
    )
    let width-body = size-body.width + inset-sep.left + inset-sep.right
    let width-tag = size-tag.width + inset-sep.left + inset-sep.right
    let body-box = box(
      radius: (top-right: 0pt, bottom-right: 0pt, rest: style.radius),
      width: width-body,
      height: max-height,
      clip: style.clip,
      fill: fill,
      stroke: stroke,
      inset: style.inset,
      outset: style.outset,
      baseline: style.baseline,
      body,
    )
    let tag-box = box(
      radius: (top-left: 0pt, bottom-left: 0pt, rest: style.radius),
      width: width-tag,
      height: max-height,
      clip: style.clip,
      fill: fill,
      stroke: stroke,
      inset: style.inset,
      outset: style.outset,
      baseline: style.baseline,
      tag + label,
    )
    [#body-box#h(0pt, weak: true)#tag-box<codly-highlight>]
  }
}

/// Renders a single code line: smart indentation, per-character highlights
/// (delegated to `codly-highlight`), and line reference figures.
// Keep the shared rendering helpers out of each line's context captures.
// Its font-dependent work still runs inside the caller's deferred context.
#let __codly-line-render(codly-highlight, codly-ref, codly-line-ref, it, line-show) = {
  let line = it.body
  let line-highlights = it.highlights
  let smart-indent = it.smart-indent
  let block-label = it.block-label
  let highlights = ()
  let layout = none
  if line-highlights != none and line-highlights.len() > 0 {
    let spans = ()
    for hl in line-highlights {
      if hl.line == line.number {
        if hl.at("label", default: none) != none {
          hl.insert("line-number", line.number)
          hl.insert("block-label", block-label)
        }
        highlights.push(hl)
        spans.push((hl.start, hl.end))
      }
    }
    if highlights.len() > 0 { layout = __codly-highlight-layout(spans) }
  }
  if layout != none {
    let sorted = ()
    for (depth, _, _, index) in layout.order {
      let hl = highlights.at(index)
      hl.insert("depth", -depth)
      sorted.push(hl)
    }
    highlights = sorted
  }

  // Keep empty and highlighted lines at a consistent height.
  let line-height = measure[1].height
  let body = line.body
  let wrap-data = none
  let needs-marker = false
  if smart-indent and it.__wrap != none {
    // Highlight insets can change the width. Measure their ordinary renderer
    // before deciding whether to add any probes to this source row.
    let natural = if highlights.len() == 0 { line.body } else {
      line-show(codly-highlight, codly-ref, codly-line-ref, it + (__wrap: none))
    }
    needs-marker = measure(natural).width > it.__wrap.width
  }
  if needs-marker {
    let row = it.__wrap.row
    let marker = it.__wrap.marker
    let advance = measure(marker).width + 0.3em.to-absolute()
    wrap-data = (
      owner: it.__wrap.owner,
      row: row,
      marker: marker,
      advance: advance,
      tolerance: line-height / 2,
    )
    body = wrap.annotate(body, it.__wrap.owner, row)
  }
  body = box(height: line-height, width: 0pt, baseline: 0pt) + body

  // Continue wrapped lines at their original indentation.
  let width = none
  let prefix = if smart-indent { line.text.match(indent.leading-spaces).text } else { "" }
  if smart-indent {
    if prefix != "" { width = measure(text(prefix)).width }
  }
  if wrap-data != none {
    wrap-data.insert("indent", if width == none { 0pt } else { width })
    width = wrap-data.indent + wrap-data.advance
  }
  let highlight-options(start) = {
    // Use the actual fragment start: highlight positions are one-based and
    // whitespace runs are atomic; crossing spans may also reopen later.
    let remaining = calc.max(prefix.len() - start, 0)
    if not smart-indent or (remaining == 0 and wrap-data == none) { return (:) }
    (
      __continuation-indent: measure(text(" " * remaining)).width
        + if wrap-data == none { 0pt } else { wrap-data.advance },
    )
  }

  // Split before applying `set par`, which would otherwise wrap each fragment.
  let highlighted = body
  if highlights.len() > 0 {
    let source = __codly-line-body(body, layout.boundaries)
    let pending = layout.pending

    // Descending indices keep the outer highlights first without re-sorting.
    let next = 0
    let next-end = calc.inf
    let active = ()
    let open = ()
    let groups = ((),)
    let starts = ()
    let i = 0
    for child in source {
      let end = i + __codly-line-length(child)
      let changed = false
      if i >= next-end {
        let remaining = ()
        for index in active {
          if i < highlights.at(index).end { remaining.push(index) }
        }
        active = remaining
        changed = true
      }
      while next < pending.len() and pending.at(next).first() <= end {
        let index = pending.at(next).last()
        let hl = highlights.at(index)
        // Expired spans cannot rejoin; duplicate records apply only once.
        if i < hl.end {
          let position = 0
          let duplicate = false
          for other in active {
            if highlights.at(other) == hl {
              duplicate = true
              break
            }
            if other > index { position += 1 }
          }
          if not duplicate {
            active.insert(position, index)
            changed = true
          }
        }
        next += 1
      }

      if changed {
        next-end = calc.inf
        for index in active {
          next-end = calc.min(next-end, highlights.at(index).end)
        }

        // Keep shared outer highlights open across changes to their children.
        let shared = 0
        while (
          shared < calc.min(open.len(), active.len()) and open.at(shared) == active.at(shared)
        ) {
          shared += 1
        }
        while open.len() > shared {
          let hl = highlights.at(open.pop())
          let content = codly-highlight(groups.pop().join(), highlight: hl, ..highlight-options(
            starts.pop(),
          ))
          groups.last().push(content)
        }
        while open.len() < active.len() {
          open.push(active.at(open.len()))
          groups.push(())
          starts.push(i)
        }
      }
      groups.last().push(child)
      i = end
    }

    // Close spans that continue through or beyond the end of the line.
    while open.len() > 0 {
      let hl = highlights.at(open.pop())
      let content = codly-highlight(groups.pop().join(), highlight: hl, ..highlight-options(
        starts.pop(),
      ))
      groups.last().push(content)
    }

    highlighted = groups.first().join()
  }

  if width != none {
    highlighted = {
      set par(hanging-indent: width)
      highlighted
    }
  }

  if wrap-data != none { highlighted = [#metadata(wrap-data)<__codly-wrap-row>#highlighted] }
  let output = raw.line(line.number, line.count, line.text, highlighted)
  if block-label == none {
    // End the paragraph while its hanging indent is in scope. Unlike an
    // empty placement, this boundary needs no positioned frame.
    return output + parbreak()
  }

  let number = line.number
  let reference = it.reference
  if reference != none { number = reference.number }
  let line-label = label(
    str(block-label)
      + ":"
      + if reference == none {
        str(number)
      } else {
        reference.label
      },
  )
  [#output#place(hide(pdf.artifact[#figure(
        kind: "codly-line",
        supplement: none,
        caption: none,
        outlined: false,
        numbering: (..) => codly-line-ref(
          [],
          block: block-label,
          number: number,
          suffix: if reference == none { none } else { reference.suffix },
        ),
        [],
      )#line-label]))]
}

#let __codly-line-show(
  codly-highlight,
  codly-ref,
  codly-line-ref,
  it,
) = {
  let line = it.body

  // Skip placeholders and other non-line content are rendered as-is.
  if type(line) != content or line.func() != raw.line {
    return line
  }

  // The renderer needs no element metadata or grid-cell styling fields.
  let it = (
    body: line,
    highlights: it.highlights,
    smart-indent: it.smart-indent,
    block-label: it.block-label,
    reference: if it.block-label != none { it.reference },
    __wrap: if it.smart-indent { it.__wrap },
  )
  let smart-indent = it.smart-indent
  if smart-indent and it.__wrap != none and "width" not in it.__wrap {
    return layout(size => __codly-line-show(
      codly-highlight,
      codly-ref,
      codly-line-ref,
      it + (__wrap: it.__wrap + (width: size.width)),
    ))
  }
  context __codly-line-render(
    codly-highlight,
    codly-ref,
    codly-line-ref,
    it,
    __codly-line-show,
  )
}

#let __codly-annotation-cell(constructor, body, label, num, numbering) = {
  block(height: 1fr, layout(size => constructor(
    body,
    label,
    num: num,
    numbering: numbering,
    height: size.height,
  )))
}

/// Resolve syntax-highlighted content before constructing the line element so
/// its show rules, highlights, indentation, and references see a real raw.line.
#let __codly-sublang-line(constructor, line, source: none, ..args) = context {
  let record = query(selector(source).before(here())).last(default: none)
  let resolved = if record == none { line } else { record.value }
  constructor(
    raw.line(line.number, line.count, resolved.text, resolved.body),
    ..args,
  )
}

#let __codly-line-loop(
  codly-line,
  codly-number,
  smart-skip,
  lines,
  annotations,
  ranges,
  skips,
  skip-last-empty,
  number-enabled,
  skip-line,
  skip-number,
  codly-annotation,
  codly-annotation-ref,
  ref-set,
  highlights,
  smart-indent,
  block-label,
  offset,
  lang-block,
  sublang-lines: (:),
  indentation: none,
  wrap-settings: none,
  unnumbered: (),
) = {
  let items = ()
  let lines_to_number = ()
  let guide-depths = ()
  let last-number = none
  let smart-skip-enabled = smart-skip.first or smart-skip.last or smart-skip.rest
  let current-annot = none
  let annotation-cell = none
  let annotation-rows = 0
  let annots = 0
  let in-skip = false
  let in-first = true
  let has-annots = annotations.len() > 0
  let skip-index = 0
  let formatted-skips = 0
  let line-array = type(skip-line) == array
  let number-array = type(skip-number) == array
  let fallback-line = if line-array { skip-line.at(-1, default: __default("skip-line")) } else {
    skip-line
  }
  let fallback-number = if number-array {
    skip-number.at(-1, default: __default("skip-number"))
  } else { skip-number }
  let unnumbered-by-line = (:)
  if unnumbered != none {
    for entry in unnumbered {
      unnumbered-by-line.insert(str(entry.line), entry.fill)
    }
  }
  let unnumbered-after = 0
  let range-index = 0
  let has-ranges = ranges != none and ranges.len() > 0
  let last-line = lines.len()
  if has-ranges and skip-last-empty and last-line > 0 and lines.last().text.trim() == "" {
    last-line -= 1
  }

  // Index once per block instead of passing every highlight to every line.
  let highlights-by-line = (:)
  let has-highlights = highlights != none and highlights.len() > 0
  if has-highlights {
    for hl in highlights {
      let key = str(hl.line)
      if key not in highlights-by-line {
        highlights-by-line.insert(key, ())
      }
      highlights-by-line.at(key).push(hl)
    }
  }

  for line in lines {
    if has-annots {
      let annot = annotations.at(annotations.len() - 1, default: none)
      if annot != none and line.number == annot.start {
        current-annot = annot
        annots += 1
      }

      if current-annot != none and line.number > current-annot.end {
        if annotation-cell != none {
          items.at(annotation-cell) = grid.cell(
            rowspan: annotation-rows,
            align: left + horizon,
            items.at(annotation-cell),
          )
          annotation-cell = none
          annotation-rows = 0
        }
        current-annot = none
        _ = annotations.pop()
        let annot = annotations.at(annotations.len() - 1, default: none)
        if annot != none and line.number == annot.start {
          current-annot = annot
          annots += 1
        }
      }
    }

    let explicit-skip-data = skips.at(skip-index, default: none)
    let explicit-skip = explicit-skip-data != none and line.number == explicit-skip-data.position
    if has-ranges {
      while range-index < ranges.len() and ranges.at(range-index).last() < line.number {
        range-index += 1
      }
    }
    let interval = if has-ranges { ranges.at(range-index, default: none) }
    let in-range = not has-ranges or (interval != none and interval.first() <= line.number)
    let insert-skip = (
      smart-skip-enabled
        and not in-range
        and not in-skip
        and if in-first {
          smart-skip.first
        } else if interval != none and interval.first() <= last-line {
          smart-skip.rest
        } else {
          smart-skip.last
        }
    )

    if explicit-skip or insert-skip {
      if number-enabled {
        let number = if explicit-skip and number-array {
          skip-number.at(formatted-skips, default: fallback-number)
        } else { fallback-number }
        items.push(codly-number(if number == none { [] } else { number }))
      }
      let body = if explicit-skip and line-array {
        skip-line.at(formatted-skips, default: fallback-line)
      } else { fallback-line }
      let body = codly-line(body)
      items.push(if has-annots {
        grid.cell(colspan: if annotation-cell == none { 2 } else { 1 }, body)
      } else { body })
      if annotation-cell != none { annotation-rows += 1 }
      lines_to_number.push(-99999999)
      if indentation != none { guide-depths.push(0) }
      if explicit-skip {
        formatted-skips += 1
        offset += explicit-skip-data.length
        skip-index += 1
        while skip-index < skips.len() and skips.at(skip-index) == explicit-skip-data {
          skip-index += 1
        }
      }
    }

    if not in-range {
      in-skip = true
      continue
    }
    in-skip = false

    if skip-last-empty and line.number == line.count and line.text.trim() == "" {
      continue
    }

    let number = line.number + offset
    let fill = unnumbered-by-line.at(str(line.number), default: none)
    let unnumbered-line = fill != none
    let reference = none
    if unnumbered-line {
      unnumbered-after += 1
      number -= 1
      reference = (
        label: "l" + str(number) + "p" + str(unnumbered-after),
        number: number,
        suffix: [+#unnumbered-after],
      )
      // Keep subsequent displayed numbers contiguous with the prior line.
      offset -= 1
      lines_to_number.push(-99999998)
    } else {
      unnumbered-after = 0
      lines_to_number.push(number)
      last-number = number
    }
    if indentation != none { guide-depths.push(indentation.depths.at(line.number - 1)) }
    if number-enabled {
      items.push(codly-number(if unnumbered-line { fill } else { number }))
    }

    // The line's number carries the offset, matching its displayed number.
    let numbered = if number == line.number { line } else {
      raw.line(number, line.count, line.text, line.body)
    }
    let line-source = sublang-lines.at(str(line.number), default: none)
    let render = if line-source == none { codly-line } else {
      __codly-sublang-line.with(codly-line, source: line-source)
    }
    let rendered-line = render(
      numbered,
      highlights: if has-highlights {
        highlights-by-line.at(str(number), default: ())
      } else { highlights },
      smart-indent: smart-indent,
      __wrap: if wrap-settings == none { none } else { wrap-settings + (row: line.number) },
      block-label: block-label,
      reference: reference,
    )
    if in-first {
      in-first = false
      rendered-line += lang-block
    }
    items.push(if has-annots {
      grid.cell(colspan: if current-annot != none { 1 } else { 2 }, rendered-line)
    } else {
      rendered-line
    })

    if current-annot != none and annotation-cell == none {
      let label = if current-annot.label != none {
        place(hide(pdf.artifact[#figure(
            kind: "codly-referencer",
            supplement: none,
            numbering: (..) => codly-annotation-ref(
              [],
              block: block-label,
              line: number,
              item: if current-annot.content == none { str(annots) } else { current-annot.content },
              suffix: if reference == none { none } else { reference.suffix },
              by: ref-set.by,
            ),
            [],
          )#current-annot.label]))
      } else {
        []
      }

      annotation-cell = items.len()
      items.push(__codly-annotation-cell(
        codly-annotation,
        current-annot.content,
        label,
        annots,
        current-annot.numbering,
      ))
    }
    if annotation-cell != none { annotation-rows += 1 }
  }

  if annotation-cell != none {
    items.at(annotation-cell) = grid.cell(
      rowspan: annotation-rows,
      align: left + horizon,
      items.at(annotation-cell),
    )
  }

  (
    items: items,
    lines_to_number: lines_to_number,
    last-number: last-number,
    guide-depths: guide-depths,
  )
}

#let __codly-annotation-show(
  it,
) = {
  // Preserve the equation's typography and unbreakable layout for accessible text.
  let body = text(
    font: "New Computer Modern Math",
    weight: 450,
  )[#pdf.artifact[$lr(}, size: #it.height)$]
    #(it.numbering)(it.num)
    #it.body
    #it.label]
  box(width: measure(body).width, body)
}

// Share static captures across blocks while keeping the style lookup deferred.
#let __codly-block-render(
  get,
  block-show,
  codly-line,
  codly-highlight,
  codly-lang,
  codly-header,
  codly-footer,
  codly-number,
  codly-annotation,
  codly-annotation-ref,
  codly-ref,
  sublang-block,
  constructor,
  args,
  alias-style,
  it,
  prepared-lines: none,
) = {
  if args.alias == none and args.aliases != none {
    if it.lang != none {
      if it.lang in args.aliases {
        let aliased-args = args
        let _ = aliased-args.remove("alias")
        let target-lang = args.aliases.at(it.lang)
        let raw-args = (:)
        let safe-resource(value) = (
          type(value) != str
            and (
              type(value) != array or value.all(value => type(value) != str)
            )
        )
        if not safe-resource(it.theme) and it.theme != alias-style.theme {
          panic(
            "codly: aliases cannot safely copy an explicit string `raw.theme`; use `path(\"...\")` or `read(\"...\")`",
          )
        }
        if not safe-resource(it.syntaxes) and it.syntaxes != alias-style.syntaxes {
          panic(
            "codly: aliases cannot safely copy explicit string `raw.syntaxes`; use `path(\"...\")` or `read(\"...\")`",
          )
        }
        if safe-resource(it.theme) { raw-args.insert("theme", it.theme) }
        if safe-resource(it.syntaxes) { raw-args.insert("syntaxes", it.syntaxes) }
        return context {
          set text(size: alias-style.size)
          constructor(
            raw(
              it.text,
              block: true,
              align: it.align,
              lang: target-lang,
              tab-size: it.tab-size,
              ..raw-args,
            ),
            alias: it.lang,
            ..aliased-args,
          )
        }
      }
    }
  }

  if args.rainbow != none and args.rainbow.enabled {
    if args.rainbow.pairs.len() > 0 and it.text.contains(rainbow.delimiters) {
      let settings = e.fields(args.rainbow)
      let sublangs = args.sublangs
      let prepared = args + (rainbow: none, sublangs: none)
      // Resolve inherited guide colors before the delimiter pass clears rainbow.
      if args.indent-guides != none and args.indent-guides.enabled {
        let guides = e.fields(args.indent-guides)
        let style = indent.settings(guides, args.rainbow)
        prepared.indent-guides = (
          guides + (rainbow: true, palette: style.palette, depth-offset: style.depth-offset)
        )
      }
      return rainbow.prepare(it, settings, sublangs, lines => block-show(
        codly-line,
        codly-highlight,
        codly-lang,
        codly-header,
        codly-footer,
        codly-number,
        codly-annotation,
        codly-annotation-ref,
        codly-ref,
        sublang-block,
        constructor,
        prepared,
        alias-style,
        it,
        prepared-lines: lines,
      ))
    }
  }

  let lang = if args.alias == none {
    it.lang
  } else {
    args.alias
  }

  // Build the language block.
  let lang-block = if lang != none {
    // construct externally to minimize hashing
    let lang-block = codly-lang(
      lang,
    )

    let lang-settings = get(codly-lang)
    place(
      lang-settings.align,
      dx: lang-settings.outset.x,
      dy: lang-settings.outset.y,
      lang-block,
    )
  }

  let has-annotations = args.annotations != none and args.annotations.len() > 0
  let column-count = (
    (if args.number-enabled { 2 } else { 1 }) + (if has-annotations { 1 } else { 0 })
  )

  let header-block = if args.header != none {
    let fields = if e.eid(args.header) == e.eid(codly-header) { e.fields(args.header) } else {
      (body: args.header)
    }
    let body = fields.remove("body")
    let header = codly-header(body + lang-block, ..fields)
    let header-set = get(codly-header) + fields
    let cell-args = __codly-cell-args(
      header-set.align,
      header-set.breakable,
      header-set.fill,
      header-set.inset,
      header-set.stroke,
    )

    (
      grid.header(
        repeat: header-set.repeat,
        grid.cell(
          header,
          colspan: column-count,
          rowspan: 1,
          x: 0,
          y: 0,
          ..cell-args,
        ),
      ),
    )
  } else {
    ()
  }

  let footer-block = if args.footer != none {
    let fields = if e.eid(args.footer) == e.eid(codly-footer) { e.fields(args.footer) } else {
      (body: args.footer)
    }
    let body = fields.remove("body")
    let footer = codly-footer(body, ..fields)
    let footer-set = get(codly-footer) + fields
    let cell-args = __codly-cell-args(
      footer-set.align,
      footer-set.breakable,
      footer-set.fill,
      footer-set.inset,
      footer-set.stroke,
    )

    (
      grid.footer(
        repeat: footer-set.repeat,
        grid.cell(
          footer,
          colspan: column-count,
          rowspan: 1,
          ..cell-args,
        ),
      ),
    )
  } else {
    ()
  }

  // Process skips.
  let skips = if args.skips != none {
    args.skips.sorted(key: x => x.position)
  } else {
    ()
  }

  // Process range/ranges.
  let std-range = range
  let range = args.range
  let ranges = args.ranges
  if range != none and ranges != none {
    panic("codly: cannot specify both `range` and `ranges`")
  } else if range != none {
    ranges = (range,)
  }

  if ranges != none { ranges = __codly-ranges(ranges) }

  let annotations = if args.annotations == none { () } else {
    args.annotations.sorted(key: annot => -annot.start)
  }
  let previous = none
  for annot in annotations {
    if args.block-label == none and annot.label != none {
      panic(
        "codly: annotations with labels (" + str(annot.label) + ") require `block-label` to be set",
      )
    }
    if previous != none and annot.end >= previous {
      panic("codly: overlapping annotations")
    }
    previous = annot.start
  }

  // handle number formatting
  let numbers-format = if args.number-enabled {
    codly-number
  } else {
    none
  }

  // handle offset and `offset-from`:
  let offset = args.offset
  if args.offset-from != none {
    let last-number = __codly-block-info(args.offset-from).last-number
    if last-number != none {
      offset += last-number
    }
  }

  let highlighted-by-line = (:)
  if args.highlighted != none {
    let default-fill = auto
    for hl in args.highlighted {
      let fill = hl.color
      if fill == none {
        if default-fill == auto {
          let settings = get(codly-highlight)
          default-fill = (settings.fill)(settings.color)
        }
        fill = default-fill
      }
      highlighted-by-line.insert(str(hl.line), fill)
    }
  }

  let ref-set = if annotations.len() > 0 and args.block-label != none {
    let settings = get(codly-ref)
    (by: settings.by, sep: settings.sep, numbering: settings.numbering)
  }

  // Resolve sublanguage syntax through metadata, retaining the original source
  // lines for range/skip/annotation processing. The line loop resolves each
  // displayed line before codly-line applies its character-level formatting.
  let output-blocks = ()
  let sublang-lines = (:)
  let lines = if prepared-lines == none { it.lines } else { prepared-lines }
  if args.sublangs != none and args.sublangs.len() > 0 {
    let nl-regex = regex("(\r\n|\r|\n)")
    let raw-text-lines = it.text.split(nl-regex)
    for (idx, s) in args.sublangs.enumerate() {
      let source-lines = raw-text-lines.slice(s.start - 1, s.end)
      let new-block = raw(
        source-lines.join("\n"),
        block: true,
        lang: s.lang,
        align: it.align,
        tab-size: it.tab-size,
        theme: it.theme,
        syntaxes: it.syntaxes,
      )

      output-blocks.push(sublang-block(new-block, idx))
      let idx = str(idx)

      for i in std-range(source-lines.len()) {
        sublang-lines.insert(
          str(s.start + i),
          label("__codly_sublang_line_" + idx + "_" + str(i)),
        )
      }
    }
  }

  // Handling of `smart-skip`
  let smart-skip = args.smart-skip
  let guides = args.indent-guides
  let wrap-settings = if args.smart-indent and args.wrap-marker != none and args.wrap-marker != [] {
    (owner: here(), marker: args.wrap-marker)
  }
  let indentation = if guides != none and guides.enabled {
    indent.scan(lines.map(l => l.text), width: guides.width, blank-lines: guides.blank-lines)
  }
  let (
    items: items,
    lines_to_number: lines_to_number,
    last-number: last-number,
    guide-depths: guide-depths,
  ) = __codly-line-loop(
    codly-line,
    codly-number,
    smart-skip,
    lines,
    annotations,
    ranges,
    skips,
    args.skip-last-empty,
    args.number-enabled,
    args.skip-line,
    args.skip-number,
    codly-annotation,
    codly-annotation-ref,
    ref-set,
    args.highlights,
    args.smart-indent,
    args.at("block-label", default: none),
    offset,
    if args.header == none { lang-block } else { [] },
    sublang-lines: sublang-lines,
    indentation: indentation,
    wrap-settings: wrap-settings,
    unnumbered: args.unnumbered,
  )

  // The header counts as a line for zebra striping purposes.
  if args.header != none {
    lines_to_number.insert(0, -999999999)
    if indentation != none { guide-depths.insert(0, 0) }
  }

  let get-line = get(codly-line)
  let line-fill = get-line.fill
  let zebra-fill = get-line.zebra-fill
  let fill = get-line.fill

  let line_colors = ()
  if highlighted-by-line.len() > 0 {
    for (i, line) in lines_to_number.enumerate() {
      let highlighted = highlighted-by-line.at(str(line), default: none)
      if highlighted != none {
        line_colors.push(highlighted)
      } else if zebra-fill != none and calc.rem(i, 2) == 0 {
        line_colors.push(zebra-fill)
      } else {
        line_colors.push(line-fill)
      }
    }
  }

  let number-settings = get(codly-number)
  let numbers-outside = number-settings.placement == "outside"
  let numbers-enabled = args.number-enabled
  let annot-width = auto
  let padding = __codly-inset(get-line.inset)
  let grid-inset = (
    top: padding.top * 1.5,
    right: padding.right * 1.5,
    bottom: padding.bottom * 1.5,
    left: padding.left * 1.5,
  )
  let numbers-alignment = number-settings.align
  let outside-column = numbers-enabled and numbers-outside
  let number-fill = number-settings.fill
  let zebra-rows = if numbers-enabled { lines_to_number.len() } else { calc.inf }
  let cell-fill = (x, y) => if numbers-enabled and x == 0 and number-fill == none {
    none
  } else {
    let base = if y < zebra-rows and zebra-fill != none and calc.rem(y, 2) == 0 {
      zebra-fill
    } else { fill }
    let code-fill = if line_colors == () { base } else { line_colors.at(y, default: base) }
    if numbers-enabled and x == 0 {
      if number-fill == auto { code-fill } else { number-fill }
    } else {
      code-fill
    }
  }
  let stroke = get-line.stroke
  let stroke-inset = if stroke == none { 0pt } else if stroke.thickness == auto { 0.5pt } else {
    stroke.thickness / 2
  }

  let grid-content = (intrinsic: false) => {
    let code-width = if intrinsic { auto } else { 1fr }
    set block(breakable: true)
    if (
      outside-column
        or wrap-settings != none
        or (indentation != none and guide-depths.any(d => d > 0))
    ) {
      geometry.outside(
        (if args.number-enabled { (auto,) } else { () })
          + (code-width,)
          + (if has-annotations { (annot-width,) } else { () }),
        grid-inset,
        (numbers-alignment, left + horizon),
        cell-fill,
        if outside-column { stroke } else { none },
        if outside-column { args.radius } else { 0pt },
        header-block,
        items,
        footer-block,
        code-column: if args.number-enabled { 1 } else { 0 },
        outside: outside-column,
        wraps: wrap-settings,
        guides: if indentation == none { none } else {
          (
            indent.settings(guides, args.rainbow)
              + (
                depths: guide-depths,
                width: indentation.width,
                // Raw code uses a monospaced font, so guide positions are
                // integral space advances. Measure that advance once per
                // block instead of once for every row and nesting level.
                step: measure(text(" " * indentation.width)).width,
                inset: grid-inset.left,
                // Unindented continuation text must not run through a guide.
                max-height: if args.smart-indent { none } else {
                  (
                    measure[1].height
                      + grid-inset.top.to-absolute()
                      + grid-inset.bottom.to-absolute()
                  )
                },
              )
          )
        },
      )
    } else if numbers-format != none {
      grid(
        columns: if has-annotations {
          (auto, code-width, annot-width)
        } else {
          (auto, code-width)
        },
        inset: grid-inset,
        stroke: none,
        align: (numbers-alignment, left + horizon),
        fill: cell-fill,
        column-gutter: 0pt,
        gutter: 0pt,
        row-gutter: 0pt,
        ..header-block,
        ..items,
        ..footer-block,
      )
    } else {
      grid(
        columns: if has-annotations {
          (code-width, annot-width)
        } else {
          code-width
        },
        inset: grid-inset,
        stroke: none,
        align: (numbers-alignment, left + horizon),
        fill: cell-fill,
        column-gutter: 0pt,
        gutter: 0pt,
        row-gutter: 0pt,
        ..header-block,
        ..items,
        ..footer-block,
      )
    }
  }

  let render-block = (width, intrinsic: false) => block(
    breakable: args.breakable,
    clip: not outside-column,
    width: width,
    radius: args.radius,
    stroke: if outside-column { none } else { get-line.stroke },
    inset: stroke-inset,
    outset: if outside-column { 0pt } else { -stroke-inset },
    grid-content(intrinsic: intrinsic),
  )

  let block_content = if args.width == auto {
    layout(size => {
      // A fractional code column collapses during an unconstrained measure.
      // Use an auto code column for the natural width, then cap the complete
      // rendered block (grid insets, number/annotation columns, and border)
      // to the width available after the surrounding margins.
      let natural-width = measure(render-block(auto, intrinsic: true)).width
      render-block(calc.min(natural-width, size.width))
    })
  } else {
    render-block(args.width)
  }

  // Empty native reference anchors need no figure layout.
  show figure.where(kind: "codly-line"): it => {
    set align(left + horizon)
    it.body
  }

  set par(justify: false, first-line-indent: 0pt)

  output-blocks.join()
  block_content

  [#metadata((last-number: last-number, lines: it.lines.len()))<__codly-block>]
}

#let __codly-show(
  codly-line,
  codly-highlight,
  codly-lang,
  codly-header,
  codly-footer,
  codly-number,
  codly-annotation,
  codly-annotation-ref,
  codly-ref,
  sublang-block,
  constructor,
  args,
  alias-style,
  it,
  prepared-lines: none,
) = e.get(get => __codly-block-render(
  get,
  __codly-show,
  codly-line,
  codly-highlight,
  codly-lang,
  codly-header,
  codly-footer,
  codly-number,
  codly-annotation,
  codly-annotation-ref,
  codly-ref,
  sublang-block,
  constructor,
  args,
  alias-style,
  it,
  prepared-lines: prepared-lines,
))

#let typst-icon = (
  typ: (
    name: "Typst",
    icon: pdf.artifact(box(
      image("typst-small.png", height: 0.8em),
      baseline: 0.1em,
      inset: 0pt,
      outset: 0pt,
    )),
    color: rgb("#239DAD"),
  ),
  typc: (
    name: "Typst code",
    icon: pdf.artifact(box(
      image("typst-small.png", height: 0.8em),
      baseline: 0.1em,
      inset: 0pt,
      outset: 0pt,
    )),
    color: rgb("#239DAD"),
  ),
)
