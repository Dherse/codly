#import "@preview/elembic:1.1.1" as e

/// The prefix identifying codly's custom elements and types.
#let __codly-prefix = "@preview/codly:v2.0.0"

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

#let __filter_elembic_args(
  args
) = {
  let _ = args.remove("body");
  let _ = args.remove("alias");
  let _ = args.remove("__elembic_stored_element_data");
  return args
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

#let in_range(ranges, line) = {
  if ranges == none or ranges.len() == 0 {
    return true
  }

  // Return true if the line is contained in any of the ranges.
  for r in ranges {
    if r.at(0) == none {
      if line <= r.at(1) {
        return true
      }
    } else if r.at(1) == none {
      if r.at(0) <= line {
        return true
      }
    } else if r.at(0) <= line and line <= r.at(1) {
      return true
    }
  }

  return false
}

#let __codly-lang-show(
  it
) = {
  // The body is the language key as a string, e.g. "py".
  let lang-key = it.body

  // Look up the language definition, if there is one.
  let lang-def = if it.languages != none {
    it.languages.at(lang-key, default: none)
  } else {
    none
  }

  // A language definition can override any of the element's arguments, e.g.
  // `(py: (radius: 5pt))` overrides `radius` for the Python language badge.
  let arg(name) = if lang-def != none and name in lang-def {
    lang-def.at(name)
  } else {
    it.at(name)
  }

  // Resolve the display properties. When the language definition does not
  // provide a name, fall back to the un-prettified language key; when it does
  // not provide a color, fall back to the default color.
  let name = if not arg("display-name") {
    []
  } else if lang-def != none and lang-def.name != none {
    lang-def.name
  } else if lang-def != none {
    []
  } else {
    lang-key
  }
  let icon = if arg("display-icon") and lang-def != none and lang-def.icon != none {
    lang-def.icon
  } else {
    []
  }
  let color = if lang-def != none and lang-def.color != none {
    lang-def.color
  } else {
    it.default-color
  }

  // The dictionary passed to function-valued `stroke`/`fill` and to custom
  // formatters.
  let lang = (name: name, icon: icon, color: color)
  let fill = arg("fill")
  let fill = if type(fill) == function {
    fill(lang)
  } else if fill != none {
    fill
  } else {
    color
  }

  let stroke = arg("stroke")
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

  let padding = __codly-inset(arg("inset"))
  let b = measure(body)
  let badge = box(
    radius: arg("radius"),
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

/// Sorts highlights so that nested highlights are applied before the ones
/// containing them, preserving a stable order for equal spans.
#let __sort-highlights(highlights) = {
  // Check if highlight 'a' contains highlight 'b'
  let contains(a, b) = {
    // a contains b if b is fully within a's range
    // but they're not the same highlight
    (a.start <= b.start and a.end >= b.end and
      not (a.start == b.start and a.end == b.end))
  }

  // Calculate nesting depth for a highlight
  // Depth = number of highlights that contain this one
  let get-depth(h, all-highlights) = {
    let depth = 0
    for other in all-highlights {
      if contains(other, h) {
        depth += 1
      }
    }
    depth
  }

  // Add depth information to each highlight
  let with-depths = highlights.enumerate().map(((i, h)) => {
    (
      original-index: i,
      highlight: h,
      depth: get-depth(h, highlights)
    )
  })

  // Sort by:
  // 1. Depth (descending - deepest/most nested first)
  // 2. Start position (ascending)
  // 3. End position (ascending)
  // 4. Original index (to maintain stable sort)
  let sorted = with-depths.sorted(key: item => (
    -item.depth,  // Negative for descending order
    item.highlight.start,
    item.highlight.end,
    item.original-index
  ))

  // Return just the highlights without the extra metadata
  sorted.map(item => {
    item.highlight.depth = item.depth
    item.highlight
  })
}

/// The length in characters of a piece of content, where content labeled
/// `<codly-highlight>` (a tagged highlight) occupies no positions.
#let __codly-line-length(child) = {
  if child.has("label") and child.label == <codly-highlight> {
    0
  } else if child.has("text") {
    child.text.len()
  } else if child.has("children") {
    child.children.map(__codly-line-length).sum()
  } else if child.has("child") {
    __codly-line-length(child.child)
  } else if child.has("body") {
    __codly-line-length(child.body)
  } else {
    0
  }
}

/// Flattens content into a sequence of atomic children, keeping labeled
/// highlight content whole and splitting text at whitespace clusters so
/// highlights can start and end on word boundaries.
#let __codly-line-body(elem) = {
  if elem.has("label") and elem.label == <codly-highlight> {
    (elem,)
  } else if elem.has("children") {
    elem.children.map(__codly-line-body).flatten()
  } else if elem.has("child") and elem.has("styles") {
    __codly-line-body(elem.child)
      .map(x => (elem.func())(x, elem.styles))
      .flatten()
  } else if elem.has("text") {
    // Separate the whitespaces at the start of text
    let out = ()
    let whitespace = none
    for cluster in elem.text.clusters() {
      if cluster.match(regex("\\s")) != none {
        if whitespace == none {
          whitespace = cluster
        } else {
          whitespace += cluster
        }
      } else if whitespace != none {
        out.push(text(whitespace))
        out.push(text(cluster))
        whitespace = none
      } else {
        out.push(text(cluster))
      }
    }
    if whitespace != none {
      out.push(text(whitespace))
    }
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
  it,
) = e.get(get => {
  let hl = it.highlight

  let base = if hl != none and hl.fill != none { hl.fill } else { it.color }
  let override(name) = if hl != none and hl.at(name) != none {
    hl.at(name)
  } else {
    it.at(name)
  }
  let fill = override("fill")
  let stroke = override("stroke")
  let radius = override("radius")
  let clip = override("clip")
  let inset = override("inset")
  let outset = override("outset")
  let baseline = override("baseline")
  let fill = (it.fill)(base)
  let stroke = if type(it.stroke) == function {
    (it.stroke)(base)
  } else {
    it.stroke
  }

  // Build the hidden reference figure if the highlight is labeled.
  let label = if hl != none and hl.label != none {
    assert(
      hl.at("block-label", default: none) != none,
      message: "codly: for labels on highlights to work, you must have the code block contained within a figure and that figure must have a label.",
    )
    let ref-set = get(codly-ref)
    let referenced = if ref-set.by == "line" {
      (ref-set.numbering)(hl.at("line-number"))
    } else {
      assert(hl.tag != none, message: "codly: tag is required for item reference")
      hl.tag
    }

    place(hide[#figure(
      kind: "codly-referencer",
      supplement: none,
      numbering: (..) => {
        ref(hl.at("block-label"))
        ref-set.sep
        __codly-trim(referenced)
      },
      [],
    )#hl.label])
  }

  let tag = if hl != none { hl.tag } else { none }
  if tag == none {
    box(
      radius: radius,
      clip: clip,
      fill: fill,
      stroke: stroke,
      inset: inset,
      outset: outset,
      baseline: baseline,
      it.body + label,
    )
  } else {
    // With a tag, the highlight is split into a body box and a tag box whose
    // inner corners are squared off so they join seamlessly. Both boxes get an
    // explicit width: with `width: auto`, Typst would shrink them to the
    // remaining line width at the weak break point, reflowing their text.
    let inset-sep = __codly-inset(inset)
    let size-body = measure(it.body)
    let size-tag = measure(tag)
    let max-height = calc.max(
      size-body.height,
      size-tag.height,
    ) + inset-sep.top + inset-sep.bottom
    let width-body = size-body.width + inset-sep.left + inset-sep.right
    let width-tag = size-tag.width + inset-sep.left + inset-sep.right
    let body-box = box(
      radius: (top-right: 0pt, bottom-right: 0pt, rest: radius),
      width: width-body,
      height: max-height,
      clip: clip,
      fill: fill,
      stroke: stroke,
      inset: inset,
      outset: outset,
      baseline: baseline,
      it.body,
    )
    let tag-box = box(
      radius: (top-left: 0pt, bottom-left: 0pt, rest: radius),
      width: width-tag,
      height: max-height,
      clip: clip,
      fill: fill,
      stroke: stroke,
      inset: inset,
      outset: outset,
      baseline: baseline,
      tag + label,
    )
    [#body-box#h(0pt, weak: true)#tag-box<codly-highlight>]
  }
})

/// Renders a single code line: smart indentation, per-character highlights
/// (delegated to `codly-highlight`), and line reference figures.
#let __codly-line-show(
  codly-highlight,
  codly-ref,
  it,
) = e.get(get => {
  let line = it.body

  // Skip placeholders and other non-line content are rendered as-is.
  if type(line) != content or line.func() != raw.line {
    return line
  }

  let hl-eid = none
  let highlights = if it.highlights == none {
    ()
  } else {
    __sort-highlights(
      it.highlights
        .filter(x => x.line == line.number)
        .map(hl => {
          // Inject the context needed for references into the metadata record.
          hl.insert("line-number", line.number)
          hl.insert("block-label", it.block-label)
          hl
        }),
    )
  }

  // A zero-width box guarantees a consistent line height (measured once).
  let line-height = measure[1].height // + __codly-inset(get(codly-highlight).inset).top
  let body = box(height: line-height, width: 0pt, baseline: 0pt) + line.body

  // Smart indentation: turn leading whitespace into a hanging indent so that
  // line breaks continue at the same indentation level.
  let width = none
  if it.smart-indent {
    // The first textual slice is the text before the first whitespace run,
    // i.e. the indented body of the line (leading whitespace is stripped by
    // raw parsing). Measure it directly; non-textual first elements have no
    // indentation.
    if body.has("children") {
      for child in body.children {
        if child.has("text") {
          let match = child.text.match(regex("^\\s*"))
          if match != none and match.start == 0 and match.end > 0 {
            width = measure([#child.text.slice(0, match.end)]).width
          }
          break
        }
      }
    }
  }

  // Apply the highlights: walk the flattened children once, tracking which
  // highlights cover each child, keeping shared outer highlights open when
  // their nested highlights change. This must run before the indentation wrap:
  // a `set par` wrapper would otherwise be distributed to every flattened
  // child, turning each character into its own paragraph.
  let highlighted = body
  if highlights.len() > 0 {
    let source = __codly-line-body(body)

    // Since highlights are sorted deepest-first and their spans are
    // contiguous, each child can be marked with its covering stack in one
    // pass: a highlight joins when the child's character interval intersects
    // it and leaves when the interval moves past its end.
    let marked = ()
    let active = ()
    let ended = ()
    let i = 0
    for child in source {
      let child-len = __codly-line-length(child)

      // Leave highlights that ended before this child.
      active = active.filter(hl => i < hl.end)

      // Join newly covered highlights. Once a highlight has ended it cannot
      // rejoin; the covering stack is sorted by depth when grouping below.
      for hl in highlights {
        if hl not in active and i < hl.end and (i >= hl.start or i + child-len >= hl.start) and (hl not in ended) {
          active.push(hl)
        }
      }

      marked.push((child, active))
      ended += highlights.filter(hl => i + child-len >= hl.end)
      i += child-len
    }

    // Each open highlight has its own child buffer, ordered outermost first.
    // Preserve the shared prefix of successive stacks so an outer highlight
    // wraps all its plain text and nested highlights in a single element.
    let open = ()
    let groups = ((),)
    // An empty final stack closes every remaining highlight.
    marked.push((none, ()))
    for (child, stack) in marked {
      let stack = stack.sorted(key: hl => -hl.depth).rev()
      let shared = 0
      while shared < calc.min(open.len(), stack.len()) and open.at(shared) == stack.at(shared) {
        shared += 1
      }

      // Close only the changed suffix, attaching each completed highlight to
      // its parent. Crossing spans split where their parent changes.
      while open.len() > shared {
        let hl = open.pop()
        let content = codly-highlight(groups.pop().join(), highlight: hl)
        groups.last().push(content)
      }
      for hl in stack.slice(shared) {
        open.push(hl)
        groups.push(())
      }
      if child != none {
        groups.last().push(child)
      }
    }

    highlighted = groups.first().join()
  }

  // Apply the hanging indent last, around the fully assembled line.
  if width != none {
    highlighted = {
      set par(hanging-indent: width)
      highlighted
    }
  }

  let output = raw.line(line.number, line.count, line.text, highlighted)
  if it.block-label == none {
    return output + place(hide[#figure(
      kind: "__codly-raw-line",
      supplement: none,
      caption: none,
      outlined: false,
      raw.line(line.number, line.count, line.text, []),
    )])
  }

  let ref-set = get(codly-ref)
  let line-label = label(str(it.block-label) + ":" + str(line.number))
  [#figure(
    kind: "codly-line",
    supplement: none,
    caption: none,
    outlined: false,
    numbering: (..) => {
      ref(it.block-label)
      ref-set.sep
      (ref-set.numbering)(line.number)
    },
    output,
  )#line-label]
})

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
  ref-set,
  highlights,
  smart-indent,
  block-label,
  offset,
  lang-block,
) = {
  let items = ()
  let lines_to_number = ()
  let smart-skip-enabled = smart-skip.first or smart-skip.last or smart-skip.rest
  let current-annot = none
  let first-annot = false
  let annots = 0
  let in-skip = false
  let in-first = true
  let has-annots = annotations.len() > 0
  let line-height = measure[1].height // + __codly-inset(get(codly-highlight).inset).top

  for line in lines {
    first-annot = false

    let annot = annotations.at(annotations.len() - 1, default: none)
    if annot != none and line.number == annot.start {
      current-annot = annot
      first-annot = true
      annots += 1
    }

    if current-annot != none and line.number > current-annot.end {
      current-annot = none
      _ = annotations.pop()
      let annot = annotations.at(annotations.len() - 1, default: none)
      if annot != none and line.number == annot.start {
        current-annot = annot
        first-annot = true
        annots += 1
      }
    }

    let explicit-skip-data = skips.at(0, default: none)
    let explicit-skip = explicit-skip-data != none and line.number == explicit-skip-data.position
    let smart-skip = smart-skip-enabled and not in_range(ranges, line.number) and not in-skip
    let smart-skip = if smart-skip {
      if in-first {
        smart-skip.first
      } else if array.range(line.number, line.count).any(i => in_range(ranges, i)) {
        smart-skip.rest
      } else {
        smart-skip.last
      }
    } else {
      false
    }

    if explicit-skip or smart-skip {
      if number-enabled {
        items.push(codly-number(skip-number))
      }
      items.push(grid.cell(
        codly-line(skip-line),
      ))
      lines_to_number.push(-99999999)
      if explicit-skip {
        offset += explicit-skip-data.length
        _ = skips.remove(0)
      }
    }

    if not in_range(ranges, line.number) {
      continue
    }
    in-skip = false

    if skip-last-empty and line.text.trim().len() == 0 and line.number == line.count {
      continue
    }

    lines_to_number.push(line.number + offset)
    if number-enabled {
      items.push(codly-number(line.number + offset))
    }

    // The line's number carries the offset, matching its displayed number.
    let numbered = raw.line(line.number + offset, line.count, line.text, line.body)
    let rendered-line = codly-line(
      numbered,
      highlights: highlights,
      smart-indent: smart-indent,
      block-label: block-label,
    )
    if in-first {
      in-first = false
      rendered-line += lang-block
    }
    items.push(grid.cell(
      colspan: if not has-annots or current-annot != none { 1 } else { 2 },
      rendered-line,
    ))

    if current-annot != none and first-annot {
      let height = line-height * (current-annot.end - current-annot.start + 1)
      let label = if current-annot.label != none {
        let referenced = if ref-set.by == "line" {
          (ref-set.numbering)(line.number + offset)
        } else {
          if current-annot.content == none { str(annots) } else { current-annot.content }
        }
        place(hide[#figure(
          kind: "codly-referencer",
          supplement: none,
          numbering: (..) => {
            ref(block-label)
            ref-set.sep
            __codly-trim(referenced)
          },
          [],
        )#current-annot.label])
      } else {
        []
      }

      items.push(grid.cell(
        rowspan: current-annot.end - current-annot.start + 1,
        align: left + horizon,
        codly-annotation(
          current-annot.content,
          label,
          num: annots,
          height: height,
          numbering: current-annot.numbering,
        ),
      ))
    }
  }

  (items: items, lines_to_number: lines_to_number)
}

#let __codly-annotation-show(
  it
) = {
  $lr(}, size: #it.height) #(it.numbering)(it.num) #it.body #it.label$
}

#let __codly-show(
  codly-line,
  codly-lang,
  codly-header,
  codly-footer,
  codly-number,
  codly-annotation,
  codly-ref,
  args,
  it,
) = e.get(get => {
  let cstr = args.__elembic_stored_element_data.default-constructor
  let lines_to_number = ()

  if args.alias == none and args.aliases != none {
    if it.lang != none {
      if it.lang in args.aliases {
        return cstr(
          raw(
            it.text,
            block: true,
            align: it.align,
            lang: args.aliases.at(it.lang),
            theme: it.theme,
            syntaxes: it.syntaxes,
            tab-size: it.tab-size,
          ),
          alias: it.lang,
          ..__filter_elembic_args(args)
        )
      }
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
      right + horizon,
      dx: lang-settings.outset.x,
      dy: lang-settings.outset.y,
      lang-block
    )
  }
  let lb = measure(lang-block)

  // Build the header
  let header-block = if args.header != none {
    // check if the header is a `codly-header` element, if not, wrap it in one
    let header = if e.eid(args.header) == e.eid(codly-header) {
      codly-header(
        args.header.body + lang-block,
        ..e.fields(args.header, exclude: ["body"])
      )
    } else {
      codly-header(
        args.header + lang-block,
      )
    }

    // auto allows external set rules to override the header cell args
    let header-set = get(codly-header)
    let colspan = if args.number-enabled { 2 } else { 1 }
    let cell_args = (colspan: colspan, rowspan: 1, x: 0, y: 0)
    if header-set.align != auto {
      cell_args.align = header-set.align
    }
    if header-set.breakable != auto {
      cell_args.breakable = header-set.breakable
    }
    if header-set.fill != auto {
      cell_args.fill = header-set.fill
    }
    if header-set.inset != auto {
      cell_args.inset = header-set.inset
    }
    if header-set.stroke != auto {
      cell_args.stroke = header-set.stroke
    }

    (
      grid.header(
        repeat: header-set.repeat,
        grid.cell(
          header,
          ..cell_args
        )
      ),
    )
  } else {
    ()
  }

  // Build the footer
  let footer-block = if args.footer != none {
    // check if the footer is a `codly-header` element, if not, wrap it in one
    let footer = if e.eid(args.footer) == e.eid(codly-footer) {
      codly-footer(
        args.footer.body,
        ..e.fields(args.footer, exclude: ["body"])
      )
    } else {
      codly-footer(
        args.footer,
      )
    }

    // auto allows external set rules to override the footer cell args
    let footer-set = get(codly-footer)
    let colspan = if args.number-enabled { 2 } else { 1 }
    let cell_args = (colspan: colspan, rowspan: 1)
    if footer-set.align != auto {
      cell_args.align = footer-set.align
    }
    if footer-set.breakable != auto {
      cell_args.breakable = footer-set.breakable
    }
    if footer-set.fill != auto {
      cell_args.fill = footer-set.fill
    }
    if footer-set.inset != auto {
      cell_args.inset = footer-set.inset
    }
    if footer-set.stroke != auto {
      cell_args.stroke = footer-set.stroke
    }

    (
      grid.footer(
        repeat: footer-set.repeat,
        grid.cell(
          footer,
          ..cell_args
        )
      ),
    )
  } else {
    ()
  }

  // Process skips.
  let skips = if args.skips != none {
    args.skips.sorted(key: x => x.at(0)).dedup()
  } else {
    ()
  }

  // Process range/ranges.
  let range = args.range
  let ranges = args.ranges
  if range != none and ranges != none {
    panic("codly: cannot specify both `range` and `ranges`")
  } else if range != none {
    ranges = (range,)
  }

  // Process annotations.
  let annotations = if args.annotations != none {
    let block-label = args.at("block-label", default: none)
    // Sort the annotations in reverse order
    let annotations = args.annotations.sorted(key: x => args.annotations.len() - x.start).map(annot => {
      if annot.end == none {
        annot.insert("end", annot.start)
      }
      if block-label == none and annot.label != none {
        panic("codly: annotations with labels (" + str(annot.label) + ") require `block-label` to be set")
      }
      annot
    })

    // Check for overlapping annotations.
    let current = none
    for a in annotations {
      if current != none and a.end > current.start {
        panic("codly: overlapping annotations")
      }
      current = a
    }

    annotations
  } else {
    ()
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
    let origin = query(args.offset-from)
    if origin.len() == 0 {
      panic("codly: offset-from must be used with a valid label, could not find: " + str(offset-from))
    } else if origin.len() > 1 {
      panic("codly: offset-from must be used with a unique label, found multiple: " + str(offset-from))
    }

    let origin = origin.first()
    let end = query(figure.where(kind: "__codly-end-block").after(origin.location())).first()
    let lines = query(figure.where(kind: "__codly-raw-line").after(origin.location()).before(end.location()))
    if lines.len() > 0 {
      offset += lines.last().body.number
    }
  }

  // Handling highlighted lines
  let highlighted-by-line = ()
  if args.highlighted != none and args.highlighted.len() > 0 {
      let ix = 1
      for l in args.highlighted.sorted(key: (x) => if type(x) == int { x } else { x.at(0) }) {
        let (ln, col) =  if type(l) == int {
          (l, highlighted-default-color)
        } else if type(l) == array {
          assert(l.len() == 2, message: "codly: a highlighted line definition must be an integer or an array of two elements: the line, and the highlight color (array length mismatch)")
          let ln = l.at(0)
          assert(type(ln) == int, message: "codly: the type of a `highlighted` line must be either an integer, found: " + str(type(ln)));

          let col = l.at(1)
          assert(
            type(col) == color or type(col) == gradient or type(col) == pattern,
            message: "codly: the type of a `highlighted` color must be either a color, a gradient, or a pattern, found: " + str(type(col))
          )

          (ln, col)
        }

        while ix < ln {
          ix += 1
          highlighted-by-line.push(none)
        }

        highlighted-by-line.push(col)
        ix += 1
      }
  }

  // Handling of `smart-skip`
  let smart-skip = args.smart-skip
  let (items: items, lines_to_number: lines_to_number) = __codly-line-loop(
    codly-line,
    codly-number,
    smart-skip,
    it.lines,
    annotations,
    ranges,
    skips,
    args.skip-last-empty,
    args.number-enabled,
    args.skip-line,
    args.skip-number,
    codly-annotation,
    get(codly-ref),
    args.highlights,
    args.smart-indent,
    args.at("block-label", default: none),
    offset,
    if args.header == none { lang-block } else { [] },
  )

  // The header counts as a line for zebra striping purposes.
  if args.header != none {
    lines_to_number.insert(0, -999999999)
  }

  // If the fill or zebra color is a gradient, we will draw it on a separate layer.
  let get-line = get(codly-line)
  let line-fill = get-line.fill
  let zebra-fill = get-line.zebra-fill
  let fill = get-line.fill
  let is-complex-fill = (
    (type(line-fill) != color and line-fill != none) or (
      type(zebra-fill) != color and zebra-fill != none
    )
  )

  let width_lines_number = calc.max(2, (calc.ceil(calc.log(it.lines.len())) + 1)) * 1em

  let line_colors = ()
  for (i, line) in lines_to_number.enumerate() {
    let highlighted = highlighted-by-line.at(line - 1, default: none)
    if highlighted != none {
      line_colors.push(highlighted)
    } else if zebra-fill != none and calc.rem(i, 2) == 0 {
      line_colors.push(zebra-fill)
    } else {
      line_colors.push(line-fill)
    }
  }

  let numbers-outside = get(codly-number).placement == "outside"
  let has-annotations = annotations != none and annotations.len() > 0
  let annot-width = auto
  let padding = __codly-inset(get-line.inset)
  let numbers-alignment = get(codly-number).align
  let block_content = block(
    breakable: args.breakable,
    clip: true,
    width: 100%,
    radius: args.radius,
    stroke: if numbers-outside { none } else { get-line.stroke },
    {
      if is-complex-fill {
        // We use place to draw the fill on a separate layer.
        place(
          grid(
            columns: if has-annotations {
              (1fr, annot-width)
            } else {
              (1fr,)
            },
            stroke: none,
            inset: padding.pairs().map(((k, x)) => (k, x * 1.5)).to-dict(),
            fill: (x, y) => if zebra-fill != none and calc.rem(y, 2) == 0 {
              zebra-fill
            } else {
              fill
            },
            ..header,
            ..it.lines.map(line => hide(line)),
            ..footer,
          ),
        )
      }

      if numbers-format != none {
        grid(
          columns: if has-annotations {
            (auto, 1fr, annot-width)
          } else {
            (auto, 1fr)
          },
          inset: padding.pairs().map(((k, x)) => (k, x * 1.5)).to-dict(),
          stroke: (x,y) =>
            if numbers-outside {
              let idx_end = if has-annotations {
                2
              } else {
                1
              }

              (
                left: if x == 1 { stroke } else { none },
                right: if x == idx_end { stroke } else { none },
                top: if x != 0 and y == 0 { stroke } else { none },
                bottom: if x != 0 and y == it.lines.len() - 1 { stroke } else { none },
              )
            } else {
              none
            },
          align: (numbers-alignment, left + horizon),
          fill: if is-complex-fill {
            none
          } else {
            (x, y) => if numbers-outside and x == 0 {
              none
            } else {
              line_colors.at(y, default: fill)
            }
          },
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
            (1fr, annot-width)
          } else {
            (1fr)
          },
          inset: padding.pairs().map(((k, x)) => (k, x * 1.5)).to-dict(),
          stroke: none,
          align: (numbers-alignment, left + horizon),
          fill: (x, y) => line_colors.at(y, default: if zebra-fill != none and calc.rem(y, 2) == 0 {
            zebra-fill
          } else {
            fill
          }),
          column-gutter: 0pt,
          gutter: 0pt,
          row-gutter: 0pt,
          ..header-block,
          ..items,
          ..footer-block,
        )
      }
    },
  )

  // fix alignment of codly-line reference figures, and show only body
  show figure.where(kind: "codly-line"): it => {
    set align(left + horizon)
    it.body
  }

  // fix alignment of codly-line reference figures, and show only body
  show figure.where(kind: "__codly-raw-line"): it => {
    set align(left + horizon)
    it.body
  }

  // fix alignment of codly-line reference figures, and show only body
  show figure.where(kind: "__codly-end-block"): it => none

  set par(justify: false, first-line-indent: 0pt)

  block_content

  figure(
    kind: "__codly-end-block",
    supplement: none,
    numbering: none,
    placement: none,
    outlined: false,
    gap: 0pt,
    caption: none,
  )[]
})

#let typst-icon = (
  typ: (
    name: "Typst",
    icon: box(
      image("typst-small.png", height: 0.8em),
      baseline: 0.1em,
      inset: 0pt,
      outset: 0pt,
    ),
    color: rgb("#239DAD"),
  ),
  typc: (
    name: "Typst code",
    icon: box(
      image("typst-small.png", height: 0.8em),
      baseline: 0.1em,
      inset: 0pt,
      outset: 0pt,
    ),
    color: rgb("#239DAD"),
  ),
)
