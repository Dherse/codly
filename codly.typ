/// A language definition, see the `languages` field.
///
/// Additional, unknown fields are preserved and override the corresponding
/// `codly-lang` arguments for that language, e.g. `(py: (radius: 5pt))`
/// overrides `radius` for the Python language badge.
#let language = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix

  e.types.declare(
    "language",
    prefix: __codly-prefix,
    doc: "A language definition used for language block formatting.",
    allow-unknown-fields: true,
    fields: (
      e.field("name", e.types.union(str, content), doc: "The \"pretty\" name of the language, as a showable value.", required: true, named: true),
      e.field("color", e.types.option(e.types.paint), doc: "The color of the language, if omitted uses the default color.", default: none),
      e.field("icon", e.types.option(e.types.union(str, content)), doc: "The icon of the language, if omitted no icon is shown.", default: none),
    ),
    casts: (
      (from: dictionary),
      (from: str, with: constructor => value => constructor(name: value)),
    ),
  )
}

/// A range of lines that should use a different syntax-highlighting language.
#let __sublang-normalize(value) = {
  let start = value.at("start")
  assert(start > 0, message: "codly: sublang `start` must be greater than 0")

  let end = value.at("end")
  assert(end >= start, message: "codly: sublang `end` must be at least `start`")

  value
}

#let __sublang-parser = {
  (default-parser, fields: (:), typecheck: true) => {
    (args, include-required: true) => {
      let result = default-parser(args, include-required: include-required)
      if result.at(0) {
        result.at(1) = __sublang-normalize(result.at(1))
      }
      result
    }
  }
}

/// A syntax-highlighting language applied to an inclusive range of lines.
#let sublang = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix

  e.types.declare(
    "sublang",
    prefix: __codly-prefix,
    doc: "A syntax-highlighting language applied to a range of lines.",
    fields: (
      e.field("start", int, doc: "The first line of the range (one-indexed).", required: true, named: true),
      e.field("end", int, doc: "The last line of the range (inclusive).", required: true, named: true),
      e.field("lang", str, doc: "The syntax-highlighting language key.", required: true, named: true),
    ),
    parse-args: __sublang-parser,
    casts: (
      (from: dictionary),
    ),
  )
}

/// Configuration for smart skips, see the `smart-skip` field.
#let smart-skip = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix

  e.types.declare(
    "smart-skip",
    prefix: __codly-prefix,
    doc: "Configuration for automatically inserting skips between displayed ranges.",
    fields: (
      e.field("first", e.types.option(bool), doc: "Whether to include a skip if the start of the block is outside of the ranges.", default: none),
      e.field("last", e.types.option(bool), doc: "Whether to include a skip if the end of the code block is outside of the ranges.", default: none),
      e.field("rest", e.types.option(bool), doc: "Whether to include a skip for unspecified values and/or in the middle of the code block.", default: none),
    ),
    casts: (
      (
        from: dictionary,
        with: constructor => value => {
          let rest = value.at("rest", default: false)
          let first = value.at("first", default: rest)
          let last = value.at("last", default: rest)
          constructor(first: first, last: last, rest: rest)
        },
      ),
      (
        from: bool,
        with: constructor => value => constructor(first: value, last: value, rest: value),
      ),
    ),
  )
}

/// A single highlight, see the `highlights` field.
#let __highlight-normalize(value) = {
  let line = value.at("line")
  assert(line > 0, message: "codly: highlight `line` must be greater than 0")

  let start = value.at("start", default: none)
  if start == none {
    value.insert("start", 0)
  } else {
    assert(start >= 0, message: "codly: highlight `start` must be at least 0")
  }

  let end = value.at("end", default: none)
  if end == none {
    value.insert("end", 999999999)
  } else {
    assert(end >= 0, message: "codly: highlight `end` must be at least 0")
  }

  value
}

#let __highlight-parser = {
  (default-parser, fields: (:), typecheck: true) => {
    (args, include-required: true) => {
      let result = default-parser(args, include-required: include-required)
      if result.at(0) {
        result.at(1) = __highlight-normalize(result.at(1))
      }
      result
    }
  }
}

#let highlight = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix

  e.types.declare(
    "highlight",
    prefix: __codly-prefix,
    doc: "A highlight over part of a line of the code block.",
    fields: (
      e.field("line", int, doc: "The line number to start highlighting (one-indexed).", required: true),
      e.field("start", e.types.option(int), doc: "The character position to start highlighting, zero if omitted or `none` (zero-indexed).", default: none),
      e.field("end", e.types.option(int), doc: "The character position to end highlighting, the end of the line if omitted or `none` (zero-indexed).", default: none),
      e.field("fill", e.types.option(e.types.union(e.types.paint, function)), doc: "The fill of the highlight, defaults to the default color.", default: none),
      e.field("tag", e.types.option(e.types.union(str, content)), doc: "An optional tag to be displayed alongside the highlight.", default: none),
      e.field("inset", e.types.option(e.types.union(length, dictionary)), doc: "Overrides `codly-highlight`'s `inset`.", default: none),
      e.field("baseline", e.types.option(e.types.union(length, auto)), doc: "Overrides the highlight box baseline; `auto` preserves the content's baseline.", default: none),
      e.field("clip", e.types.option(bool), doc: "Overrides `codly-highlight`'s `clip`.", default: none),
      e.field("outset", e.types.option(e.types.union(length, dictionary)), doc: "Overrides `codly-highlight`'s `outset`.", default: none),
      e.field("radius", e.types.option(length), doc: "Overrides `codly-highlight`'s `radius`.", default: none),
      e.field("label", e.types.option(label), doc: "If and only if the code block is in a `figure`, sets the label by which the highlight can be referenced.", default: none),
      e.field("stroke", e.types.option(e.types.union(stroke, function)), doc: "Overrides `codly-highlight`'s `stroke`.", default: none),
      e.field("depth", e.types.option(int), doc: "The depth of the highlight, used to determine which highlight is on top when multiple highlights overlap. Higher depth means on top."),
    ),
    parse-args: __highlight-parser,
    casts: (
      (
        from: dictionary,
        with: constructor => value => {
          let line = value.remove("line")
          constructor(line, ..value)
        },
      ),
    ),
  )
}

/// A single annotation, see the `annotations` field.
#let __annotation-normalize(value) = {
  let start = value.at("start")
  assert(start > 0, message: "codly: annotation `start` must be greater than 0")

  let end = value.at("end", default: none)
  if end == none {
    end = start
    value.insert("end", end)
  } else {
    assert(end > 0, message: "codly: annotation `end` must be greater than 0")
  }

  assert(end >= start, message: "codly: annotation `end` must be at least `start`")

  if "content" not in value {
    value.insert("content", none)
  }

  value
}

#let __annotation-parser = {
  (default-parser, fields: (:), typecheck: true) => {
    (args, include-required: true) => {
      let result = default-parser(args, include-required: include-required)
      if result.at(0) {
        result.at(1) = __annotation-normalize(result.at(1))
      }
      result
    }
  }
}

#let annotation = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix

  e.types.declare(
    "annotation",
    prefix: __codly-prefix,
    doc: "An annotation displayed on the right side of the code block.",
    fields: (
      e.field("start", int, doc: "The line number to start the annotation (one-indexed).", required: true),
      e.field("end", e.types.option(int), doc: "The line number to end the annotation, if missing or `none` the annotation will only contain the start line.", default: none),
      e.field("content", e.types.option(content), doc: "The content of the annotation as a showable value, if missing or `none` the annotation will only contain the number.", default: none),
      e.field("label", e.types.option(label), doc: "If and only if the code block is in a `figure`, sets the label by which the annotation can be referenced.", default: none),
      e.field("numbering", e.types.option(function), doc: "The format of the annotation number, defaults to `(1)`.", default: numbering.with("(1)")),
    ),
    parse-args: __annotation-parser,
    casts: (
      (
        from: dictionary,
        with: constructor => value => {
          let start = value.remove("start")
          constructor(start, ..value)
        },
      ),
    ),
  )
}

/// A custom argument parser for the pair-like types below (range, skip,
/// highlighted-line). It allows specifying the pair's fields either
/// positionally, e.g. `range(2, 4)`, or by name, e.g. `range(start: 2, end: 4)`,
/// unlike the default parser which only accepts positional arguments for
/// required fields.
#let __pair-parser(first-field) = {
  (default-parser, fields: (:), typecheck: true) => {
    let names = fields.user-fields.keys()
    (args, include-required: true) => {
      let positional = args.pos()
      let named = args.named()
      if include-required and positional.len() == 0 and first-field in named {
        // All fields given by name: convert to positional order based on field
        // declaration order.
        let ordered = ()
        for name in names {
          if name in named {
            ordered.push(named.remove(name))
          }
        }
        // Any remaining named fields are unknown and will error in the default parser
        if named.len() > 0 {
          return default-parser(args, include-required: include-required)
        }
        default-parser(arguments(..ordered), include-required: include-required)
      } else {
        default-parser(args, include-required: include-required)
      }
    }
  }
}

/// A cast from a dictionary for the pair-like types, converting the dict to
/// positional arguments based on field order.
#let __pair-dict-cast(field-names) = {
  constructor => value => {
    let ordered = ()
    for name in field-names {
      if name in value {
        ordered.push(value.remove(name))
      }
    }
    if value.len() > 0 {
      assert(false, message: "elembic: unknown e.field(s) " + value.keys().join(", "))
    }
    constructor(..ordered)
  }
}

/// A single range of line numbers, see the `range` and `ranges` fields.
/// Can be constructed as `range(start, end)`, `range(start: .., end: ..)`,
/// or cast from the array `(start, end)`.
#let range = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix

  e.types.declare(
    "range",
    prefix: __codly-prefix,
    doc: "A range of line numbers to display (one-indexed, inclusive).",
    fields: (
      e.field("start", int, doc: "The first line of the range (one-indexed).", required: true),
      e.field("end", e.types.option(int), doc: "The last line of the range (inclusive), `none` for the rest of the block.", default: none, named: false),
    ),
    parse-args: __pair-parser("start"),
    casts: (
      (
        from: dictionary,
        with: __pair-dict-cast(("start", "end")),
      ),
      (
        from: array,
        check: value => value.len() in (1, 2),
        with: constructor => value => constructor(..value),
      ),
    ),
  )
}

/// A single skip, see the `skips` field.
/// Can be constructed as `skip(position, length)`, `skip(position: .., length: ..)`,
/// or cast from the array `(position, length)`.
#let skip = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix

  e.types.declare(
    "skip",
    prefix: __codly-prefix,
    doc: "A skip of a number of lines at a position in the code block.",
    fields: (
      e.field("position", int, doc: "The line where the skip is inserted (zero-indexed).", required: true),
      e.field("length", int, doc: "The number of lines of the skip.", default: 1, named: false),
    ),
    parse-args: __pair-parser("position"),
    casts: (
      (
        from: dictionary,
        with: __pair-dict-cast(("position", "length")),
      ),
      (
        from: array,
        check: value => value.len() in (1, 2),
        with: constructor => value => constructor(..value),
      ),
    ),
  )
}

/// A single highlighted line, see the `highlighted-lines` field.
/// Can be constructed as `highlighted-line(line)`, `highlighted-line(line, color)`,
/// or cast from an integer or an array of the form `(line, color)`.
#let highlighted-line = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix

  e.types.declare(
    "highlighted-line",
    prefix: __codly-prefix,
    doc: "A line to be highlighted, with an optional custom highlight color.",
    fields: (
      e.field("line", int, doc: "The line number to highlight (one-indexed, as shown in the document).", required: true),
      e.field("color", e.types.option(e.types.paint), doc: "The highlight color of the line, defaults to `codly-highlight`'s `fill`.", default: none, named: false),
    ),
    parse-args: __pair-parser("line"),
    casts: (
      (
        from: dictionary,
        with: __pair-dict-cast(("line", "color")),
      ),
      (
        from: int,
        with: constructor => value => constructor(value),
      ),
      (
        from: array,
        check: value => value.len() in (1, 2),
        with: constructor => value => constructor(..value),
      ),
    ),
  )
}

/// Shared formatting settings read by the line, highlight, and annotation
/// reference renderers. Generated references currently use figure numbering.
#let codly-ref = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix, __doc, __default

  e.element.declare(
    "codly-ref",
    prefix: __codly-prefix,
    doc: "A reference to a highlight or annotation of a codly code block.",
    display: it => it.body,
    fields: (
      e.field("body", e.types.option(content), doc: "The content of the reference.", required: true),
      e.field("by", e.types.option(e.types.union("line", "item")), doc: __doc("reference-by"), default: __default("reference-by")),
      e.field("sep", e.types.option(e.types.union(str, content)), doc: __doc("reference-sep"), default: __default("reference-sep")),
      e.field("numbering", e.types.option(function), doc: __doc("reference-number-format"), default: __default("reference-number-format")),
    )
  )
}

/// A single highlight within a codly code block.
#let codly-highlight = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix, __doc, __default, __codly-highlight-show

  e.element.declare(
    "codly-highlight",
    prefix: __codly-prefix,
    doc: "A highlight over part of a line of a codly code block.",
    display: __codly-highlight-show.with(codly-ref),
    fields: (
      e.field("body", e.types.option(content), doc: "The highlighted content.", required: true),
      e.field("highlight", e.types.option(highlight), doc: "The highlight metadata for this content.", default: none),
      e.field("color", e.types.paint, doc: __doc("default-color"), default: __default("default-color")),
      e.field("radius", e.types.option(length), doc: __doc("highlight-radius"), default: __default("highlight-radius")),
      e.field("fill", e.types.option(function), doc: __doc("highlight-fill"), default: __default("highlight-fill")),
      e.field("baseline", e.types.option(e.types.union(length, auto)), doc: "The highlight box baseline shift; `auto` uses Typst's content baseline.", default: 0pt),
      e.field("stroke", e.types.option(e.types.union(stroke, function)), doc: __doc("highlight-stroke"), default: __default("highlight-stroke")),
      e.field("inset", e.types.option(e.types.union(length, dictionary)), doc: __doc("highlight-inset"), default: __default("highlight-inset")),
      e.field("outset", e.types.option(e.types.union(length, dictionary)), doc: __doc("highlight-outset"), default: __default("highlight-outset")),
      e.field("clip", e.types.option(bool), doc: __doc("highlight-clip"), default: __default("highlight-clip")),
    )
  )
}

/// A single line of a codly code block. Takes over the line-level styling
/// arguments of `codly` (`radius`, `inset`, `fill`, `zebra-fill`, `stroke`).
#let codly-line = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix, __doc, __default, __codly-line-show

  e.element.declare(
    "codly-line",
    prefix: __codly-prefix,
    doc: "A single line of a codly code block.",
    display: __codly-line-show.with(codly-highlight, codly-ref),
    fields: (
      e.field("body", e.types.option(content), doc: "The content of the line.", required: true),
      e.field("radius", e.types.option(length), doc: __doc("radius"), default: __default("radius")),
      e.field("inset", e.types.option(e.types.union(length, dictionary)), doc: __doc("inset"), default: __default("inset")),
      e.field("fill", e.types.option(e.types.paint), doc: __doc("fill"), default: __default("fill")),
      e.field("zebra-fill", e.types.option(e.types.paint), doc: __doc("zebra-fill"), default: __default("zebra-fill")),
      e.field("stroke", e.types.option(stroke), doc: __doc("stroke"), default: __default("stroke")),
      e.field("highlights", e.types.option(e.types.array(highlight)), doc: __doc("highlights"), default: __default("highlights"), folds: false),
      e.field("smart-indent", bool, doc: __doc("smart-indent"), default: __default("smart-indent")),
      e.field("block-label", e.types.option(label), doc: "The label of the containing code block.", default: none),
    )
  )
}

/// The header of a codly code block. Takes over the `header-` prefixed
/// arguments of `codly`.
#let codly-header = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix, __doc, __default

  e.element.declare(
    "codly-header",
    prefix: __codly-prefix,
    doc: "The header of a codly code block.",
    display: it => it.body,
    fields: (
      e.field("body", e.types.option(content), doc: __doc("header"), required: true),
      e.field("repeat", e.types.option(bool), doc: __doc("header-repeat"), default: __default("header-repeat")),

      // Replaces the old cell-args
      e.field("align", e.types.option(alignment), doc: "todo", default: center + horizon),
      e.field("breakable", e.types.option(e.types.union(bool, auto)), doc: "todo", default: auto),
      e.field("inset", e.types.option(e.types.union(length, dictionary, auto)), doc: "todo", default: auto),
      e.field("fill", e.types.option(e.types.union(e.types.paint, auto)), doc: "todo", default: auto),
      e.field("stroke", e.types.option(e.types.union(stroke, auto)), doc: "todo", default: auto),
    )
  )
}

/// The footer of a codly code block. Takes over the `footer-` prefixed
/// arguments of `codly`.
#let codly-footer = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix, __doc, __default

  e.element.declare(
    "codly-footer",
    prefix: __codly-prefix,
    doc: "The footer of a codly code block.",
    display: it => it.body,
    fields: (
      e.field("body", e.types.option(content), doc: __doc("footer"), required: true),
      e.field("repeat", e.types.option(bool), doc: __doc("footer-repeat"), default: __default("footer-repeat")),

      // Replaces the old cell-args
      e.field("align", e.types.option(alignment), doc: "todo", default: center + horizon),
      e.field("breakable", e.types.option(e.types.union(bool, auto)), doc: "todo", default: auto),
      e.field("inset", e.types.option(e.types.union(length, dictionary, auto)), doc: "todo", default: auto),
      e.field("fill", e.types.option(e.types.union(e.types.paint, auto)), doc: "todo", default: auto),
      e.field("stroke", e.types.option(e.types.union(stroke, auto)), doc: "todo", default: auto),
    )
  )
}

/// The language badge of a codly code block. Takes over the `lang-` prefixed
/// arguments of `codly`, as well as `display-name` and `display-icon`.
#let codly-lang = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix, __doc, __default, __codly-lang-show

  e.element.declare(
    "codly-lang",
    prefix: __codly-prefix,
    doc: "The language badge of a codly code block.",
    display: __codly-lang-show,
    fields: (
      e.field("body", str, doc: "The language key, e.g. \"py\".", required: true),
      e.field("languages", e.types.option(e.types.dict(language)), doc: __doc("languages"), default: __default("languages")),
      e.field("default-color", e.types.option(e.types.paint), doc: __doc("default-color"), default: __default("default-color")),
      e.field("inset", e.types.option(e.types.union(length, dictionary)), doc: __doc("lang-inset"), default: __default("lang-inset")),
      e.field("outset", e.types.option(dictionary), doc: __doc("lang-outset"), default: __default("lang-outset")),
      e.field("radius", e.types.option(e.types.union(length, dictionary)), doc: __doc("lang-radius"), default: __default("lang-radius")),
      e.field("stroke", e.types.option(e.types.union(stroke, function)), doc: __doc("lang-stroke"), default: __default("lang-stroke")),
      e.field("fill", e.types.option(e.types.union(e.types.paint, function)), doc: __doc("lang-fill"), default: __default("lang-fill")),
      e.field("display-name", e.types.option(bool), doc: __doc("display-name"), default: __default("display-name")),
      e.field("display-icon", e.types.option(bool), doc: __doc("display-icon"), default: __default("display-icon")),
      e.field("align", e.types.option(alignment), doc: "todo", default: right + horizon),
    )
  )
}

/// A single annotation of a codly code block. Takes over the `annotation-`
/// prefixed arguments of `codly`.
#let codly-annotation = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix, __doc, __default, __codly-annotation-show

  e.element.declare(
    "codly-annotation",
    prefix: __codly-prefix,
    doc: "An annotation displayed on the right side of a codly code block.",
    display: __codly-annotation-show,
    labelable: false,
    fields: (
      e.field("body", e.types.option(content), doc: "The content of the annotation.", required: true),
      e.field("label", e.types.option(content), doc: "todo", default: "todo", required: true),
      e.field("height", e.types.option(length), doc: "todo", default: 0.0pt),
      e.field("num", e.types.option(int), doc: "todo", default: 0),
      e.field("numbering", e.types.option(function), doc: "todo", default: numbering.with("(1)")),
    )
  )
}

/// A line number of a codly code block. Takes over the `number-` prefixed
/// arguments of `codly`.
#let codly-number = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix, __doc, __default

  e.element.declare(
    "codly-number",
    prefix: __codly-prefix,
    doc: "A line number of a codly code block.",
    display: it => it.body,
    fields: (
      e.field("body", e.types.union(int, content), doc: "The line number content.", required: true),
      e.field("align", e.types.option(alignment), doc: __doc("number-align"), default: __default("number-align")),
      e.field("placement", e.types.option(e.types.union("inside", "outside")), doc: __doc("number-placement"), default: __default("number-placement")),
    )
  )
}

#let sublang-block = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix, __doc, __default

  e.element.declare(
    "sublang-block",
    prefix: __codly-prefix,
    doc: "A sublanguage block within a codly code block.",
    display: it => {
      show raw.where(block: true): raw => {
        let idx = str(it.idx)

        for (i, line) in raw.lines.enumerate() {
          let line-label = label("__codly_sublang_line_" + idx + "_" + str(i))
          [
            #metadata(line) #line-label
          ]
        }
      }

      it.body
    },
    fields: (
      e.field("body", content, doc: "The content of the sublanguage block.", required: true),
      e.field("idx", int, doc: "The index of the sublanguage block within the code block.", required: true),
    )
  )

}

#let codly = {
  import "@preview/elembic:1.1.1" as e
  import "src/lib.typ": __codly-prefix, __doc, __default

  e.element.declare(
    "codly",
    prefix: __codly-prefix,
    doc: "Codly is a library that enhances the way you write code blocks in Typst.",
    display: it => {
      if not it.enabled {
        return it.body
      }

      import "src/lib.typ": __codly-show
      let body = it.remove("body")
      let data = it.remove("__elembic_stored_element_data")
      let constructor = if it.alias == none and it.aliases != none and it.aliases.len() > 0 { data.default-constructor }
      let alias-style = if constructor != none { (size: text.size, theme: raw.theme, syntaxes: raw.syntaxes) }
      show raw.where(block: true): __codly-show.with(codly-line, codly-highlight, codly-lang, codly-header, codly-footer, codly-number, codly-annotation, codly-ref, sublang-block, constructor, it, alias-style)
      body
    },
    fields: (
      e.field("body", e.types.option(content), doc: "The row block to style", required: true),
      e.field("block-label", e.types.option(label), doc: "The label of the containing figure.", default: none),
      e.field("alias", e.types.option(str), doc: "Whether this is an already aliased block", required: false, default: none),
      e.field("enabled", e.types.option(bool), doc: __doc("enabled"), default: __default("enabled")),
      e.field("number-enabled", e.types.option(bool), doc: "todo", default: true),
      e.field("offset", e.types.option(int), doc: __doc("offset"), default: __default("offset")),
      e.field("offset-from", e.types.option(label), doc: __doc("offset-from"), default: __default("offset-from")),
      e.field("range", e.types.option(range), doc: __doc("range"), default: __default("range"), folds: false),
      e.field("ranges", e.types.option(e.types.array(range)), doc: __doc("ranges"), default: __default("ranges"), folds: false),
      e.field("smart-skip", e.types.option(smart-skip), doc: __doc("smart-skip"), default: __default("smart-skip"), folds: false),
      e.field("aliases", e.types.option(dictionary), doc: __doc("aliases"), default: __default("aliases")),
      e.field("smart-indent", e.types.option(bool), doc: __doc("smart-indent"), default: __default("smart-indent")),
      e.field("skip-last-empty", e.types.option(bool), doc: __doc("skip-last-empty"), default: __default("skip-last-empty")),
      e.field("breakable", e.types.option(bool), doc: __doc("breakable"), default: __default("breakable")),
      e.field("skips", e.types.option(e.types.array(skip)), doc: __doc("skips"), default: __default("skips"), folds: false),
      e.field("skip-line", e.types.option(e.types.union(content, e.types.array(e.types.option(content)))), doc: __doc("skip-line"), default: __default("skip-line"), folds: false),
      e.field("skip-number", e.types.option(e.types.union(content, e.types.array(e.types.option(content)))), doc: __doc("skip-number"), default: __default("skip-number"), folds: false),
      e.field("annotations", e.types.option(e.types.array(annotation)), doc: __doc("annotations"), default: __default("annotations"), folds: false),
      e.field("highlighted", e.types.option(e.types.array(highlighted-line)), doc: __doc("highlighted-lines"), default: __default("highlighted-lines"), folds: false),
      e.field("highlights", e.types.option(e.types.array(highlight)), doc: __doc("highlights"), default: __default("highlights"), folds: false),
      e.field("header", e.types.option(content), doc: __doc("header"), default: __default("header")),
      e.field("footer", e.types.option(content), doc: __doc("footer"), default: __default("footer")),
      e.field("radius", e.types.option(length), doc: __doc("radius"), default: __default("radius")),
      e.field("sublangs", e.types.option(e.types.array(sublang)), doc: "todo", default: none),
    )
  )
}


#let new = codly
#let set_(..args) = {
  import "@preview/elembic:1.1.1" as e
  e.set_(codly, ..args)
}
#let show_(it, ..args) = {
  import "@preview/elembic:1.1.1" as e
  e.show_(codly, it, ..args)
}
#let selector(..args)             = {
  import "@preview/elembic:1.1.1" as e
  e.selector(codly, ..args)
}
#let lang-set_(..args)            = {
  import "@preview/elembic:1.1.1" as e
  e.set_(codly-lang, ..args)
}
#let lang-show_(it, ..args)       = {
  import "@preview/elembic:1.1.1" as e
  e.show_(codly-lang, it, ..args)
}
#let header-set(..args)           = {
  import "@preview/elembic:1.1.1" as e
  e.set_(codly-header, ..args)
}
#let line-set_(..args)            = {
  import "@preview/elembic:1.1.1" as e
  e.set_(codly-line, ..args)
}
#let line-show_(it, ..args)       = {
  import "@preview/elembic:1.1.1" as e
  e.show_(codly-line, it, ..args)
}
#let highlight-set_(..args)       = {
  import "@preview/elembic:1.1.1" as e
  e.set_(codly-highlight, ..args)
}
#let highlight-show_(it, ..args)  = {
  import "@preview/elembic:1.1.1" as e
  e.show_(codly-highlight, it, ..args)
}
#let annotation-set_(..args)      = {
  import "@preview/elembic:1.1.1" as e
  e.set_(codly-annotation, ..args)
}
#let annotation-show_(it, ..args) = {
  import "@preview/elembic:1.1.1" as e
  e.show_(codly-annotation, it, ..args)
}
#let ref-set_(..args)             = {
  import "@preview/elembic:1.1.1" as e
  e.set_(codly-ref, ..args)
}

/// In context, read source line count and the last displayed number of a block.
#import "src/lib.typ": __codly-block-info as info
