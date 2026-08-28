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

  let format = arg("format")
  if format == none {
    return []
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

  if type(format) == function {
    return format(name, icon, color)
  }

  // `format: auto`: the default formatter.
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

#let __codly-header-show(
  it
) = {
  it.body
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
  annotation-format,
  offset,
) = {
  let items = ()
  let lines_to_number = ()
  let smart-skip-enabled = smart-skip.first or smart-skip.last or smart-skip.rest
  let current-annot = none
  let first-annot = false
  let annots = 0
  let in-skip = false
  let in-first = true

  for line in lines {
    first-annot = false

    let annot = annotations.at(0, default: none)
    if annot != none and line.number == annot.start {
      current-annot = annot
      first-annot = true
      annots += 1
    }

    if current-annot != none and line.number > current-annot.end {
      current-annot = none
      _ = annotations.remove(0)
      let annot = annotations.at(0, default: none)
      if annot != none and line.number == annot.start {
        current-annot = annot
        first-annot = true
        annots += 1
      }
    }

    let skip = skips.at(0, default: none)
    if skip != none and line.number == skip.position {
      if number-enabled {
        items.push(codly-number(skip-number))
      }
      items.push(grid.cell(
        codly-line(skip-line),
        colspan: if number-enabled { 1 } else { 2 },
      ))
      lines_to_number.push(-99999999)
      offset += skip.length
      _ = skips.remove(0)
    } else if smart-skip-enabled and not in_range(ranges, line.number) and not in-skip {
      let should-skip = if in-first {
        smart-skip.first
      } else if array.range(line.number, line.count).any(i => in_range(ranges, i)) {
        smart-skip.rest
      } else {
        smart-skip.last
      }
      if should-skip {
        if number-enabled {
          items.push(codly-number(skip-number))
        }
        items.push(grid.cell(
          codly-line(skip-line),
          colspan: if number-enabled { 1 } else { 2 },
        ))
        lines_to_number.push(-99999999)
      }
    }

    if not in_range(ranges, line.number) {
      in-skip = true
      continue
    }
    in-skip = false
    in-first = false

    if skip-last-empty and line.text.trim().len() == 0 and line.number == line.count {
      continue
    }

    lines_to_number.push(line.number + offset)
    if number-enabled {
      items.push(codly-number(line.number + offset))
    }

    items.push(grid.cell(
      codly-line(line),
      colspan: if number-enabled { 1 } else { 2 },
    ))

    if current-annot != none and first-annot {
      let annotation-number = annotation-format(annots)
      let annotation-body = [
        #annotation-number
        #current-annot.content
      ]
      items.push(grid.cell(
        rowspan: current-annot.end - current-annot.start + 1,
        align: left + horizon,
        annotation-body,
      ))
    }
  }

  (items: items, lines_to_number: lines_to_number)
}

#let __codly-show(
  it,
  args,
  codly-line,
  codly-lang,
  codly-header,
  codly-number,
  codly-annotation,
) = e.get(get => {
  let cstr = args.__elembic_stored_element_data.default-constructor
  let lines_to_number = ()

  if args.alias == none and args.aliases != none and it.lang in args.aliases {
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
    lines_to_number.push(-999999999)

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
    let cell_args = (colspan: 2, rowspan: 1, x: 0, y: 0)
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

    grid.header(
      repeat: header-set.repeat,
      grid.cell(
        header,
        ..cell_args
      )
    )
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
  }else if range != none {
    ranges = (range,)
  }

  // Process annotations.
  let annotations = if args.annotations != none {
    let annotations = args.annotations.sorted(key: x => x.start).map(annot => {
      if args.block-label == none and annot.label != none {
        panic("codly: annotations with labels (" + annot.label + ") require `block-label` to be set")
      }
      annot
    })

    // Check for overlapping annotations.
    let current = none
    for a in annotations {
      if current != none and a.start <= current.end {
        panic("codly: overlapping annotations")
      }
      current = a
    }

    annotations
  } else {
    ()
  }

  // handle number formatting
  let numbers-format = if args.number-enabled != none {
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
      offset += lines.last().body.children.at(0).number
    }
  }

  // Handling of `smart-skip`
  let smart-skip = args.smart-skip
  let annotation-settings = get(codly-annotation)
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
    annotation-settings.format,
    offset,
  )

  grid(
    columns: 2,
    header-block,
    ..items,
  )
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
