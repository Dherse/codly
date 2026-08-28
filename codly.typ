#import "@preview/elembic:1.1.1" as e: field, types
#import "src/lib.typ": (
  typst-icon,
  __codly-prefix,
  __doc,
  __default,
  __codly-show,
  __codly-lang-show,
  __codly-header-show,
)

/// A language definition, see the `languages` field.
///
/// Additional, unknown fields are preserved and override the corresponding
/// `codly-lang` arguments for that language, e.g. `(py: (radius: 5pt))`
/// overrides `radius` for the Python language badge.
#let language = e.types.declare(
  "language",
  prefix: __codly-prefix,
  doc: "A language definition used for language block formatting.",
  allow-unknown-fields: true,
  fields: (
    field("name", types.union(str, content), doc: "The \"pretty\" name of the language, as a showable value.", required: true, named: true),
    field("color", types.option(types.paint), doc: "The color of the language, if omitted uses the default color.", default: none),
    field("icon", types.option(types.union(str, content)), doc: "The icon of the language, if omitted no icon is shown.", default: none),
  ),
  casts: (
    (from: dictionary),
    (from: str, with: constructor => value => constructor(name: value)),
  ),
)

/// Configuration for smart skips, see the `smart-skip` field.
#let smart-skip = e.types.declare(
  "smart-skip",
  prefix: __codly-prefix,
  doc: "Configuration for automatically inserting skips between displayed ranges.",
  fields: (
    field("first", types.option(bool), doc: "Whether to include a skip if the start of the block is outside of the ranges.", default: none),
    field("last", types.option(bool), doc: "Whether to include a skip if the end of the code block is outside of the ranges.", default: none),
    field("rest", types.option(bool), doc: "Whether to include a skip for unspecified values and/or in the middle of the code block.", default: none),
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

/// A single highlight, see the `highlights` field.
#let highlight = e.types.declare(
  "highlight",
  prefix: __codly-prefix,
  doc: "A highlight over part of a line of the code block.",
  fields: (
    field("line", int, doc: "The line number to start highlighting (one-indexed).", required: true),
    field("start", types.option(int), doc: "The character position to start highlighting, zero if omitted or `none` (zero-indexed).", default: none),
    field("end", types.option(int), doc: "The character position to end highlighting, the end of the line if omitted or `none` (zero-indexed).", default: none),
    field("fill", types.option(types.paint), doc: "The fill of the highlight, defaults to the default color.", default: none),
    field("tag", types.option(types.union(str, content)), doc: "An optional tag to be displayed alongside the highlight.", default: none),
    field("inset", types.option(types.union(length, dictionary)), doc: "Overrides `codly-highlight`'s `inset`.", default: none),
    field("baseline", types.option(length), doc: "Overrides the baseline which is set by default to the `bottom` component of `codly-highlight`'s `inset`.", default: none),
    field("clip", types.option(bool), doc: "Overrides `codly-highlight`'s `clip`.", default: none),
    field("outset", types.option(types.union(length, dictionary)), doc: "Overrides `codly-highlight`'s `outset`.", default: none),
    field("radius", types.option(length), doc: "Overrides `codly-highlight`'s `radius`.", default: none),
    field("label", types.option(label), doc: "If and only if the code block is in a `figure`, sets the label by which the highlight can be referenced.", default: none),
  ),
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

#let annotation = e.types.declare(
  "annotation",
  prefix: __codly-prefix,
  doc: "An annotation displayed on the right side of the code block.",
  fields: (
    field("start", int, doc: "The line number to start the annotation (one-indexed).", required: true),
    field("end", types.option(int), doc: "The line number to end the annotation, if missing or `none` the annotation will only contain the start line.", default: none),
    field("content", types.option(content), doc: "The content of the annotation as a showable value, if missing or `none` the annotation will only contain the number.", default: none),
    field("label", types.option(label), doc: "If and only if the code block is in a `figure`, sets the label by which the annotation can be referenced.", default: none),
  ),
  parse-args: __annotation-parser,
  casts: (
    (
      from: dictionary,
      with: constructor => value => {
        let start = value.remove("start")
        value = __annotation-normalize((start: start, ..value))
        start = value.remove("start")
        constructor(start, ..value)
      },
    ),
  ),
)

/// A custom argument parser for the pair-like types below (range, skip,
/// highlighted-line). It allows specifying the pair's fields either
/// positionally, e.g. `range(2, 4)`, or by name, e.g. `range(start: 2, end: 4)`,
/// unlike the default parser which only accepts positional arguments for
/// required fields.
#let __pair-parser(first-field) = {
  (default-parser, fields: (:), typecheck: true) => {
    (args, include-required: true) => {
      let positional = args.pos()
      let named = args.named()
      if include-required and positional.len() == 0 and first-field in named {
        // All fields given by name: convert to positional order based on field
        // declaration order.
        let ordered = ()
        for name in fields.user-fields.keys() {
          if name in named {
            ordered.push(named.at(name))
            _ = named.remove(name)
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
        ordered.push(value.at(name))
        _ = value.remove(name)
      }
    }
    if value.len() > 0 {
      assert(false, message: "elembic: unknown field(s) " + value.keys().join(", "))
    }
    constructor(..ordered)
  }
}

/// A single range of line numbers, see the `range` and `ranges` fields.
/// Can be constructed as `range(start, end)`, `range(start: .., end: ..)`,
/// or cast from the array `(start, end)`.
#let range = e.types.declare(
  "range",
  prefix: __codly-prefix,
  doc: "A range of line numbers to display (one-indexed, inclusive).",
  fields: (
    field("start", int, doc: "The first line of the range (one-indexed).", required: true),
    field("end", types.option(int), doc: "The last line of the range (inclusive), `none` for the rest of the block.", default: none, named: false),
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

/// A single skip, see the `skips` field.
/// Can be constructed as `skip(position, length)`, `skip(position: .., length: ..)`,
/// or cast from the array `(position, length)`.
#let skip = e.types.declare(
  "skip",
  prefix: __codly-prefix,
  doc: "A skip of a number of lines at a position in the code block.",
  fields: (
    field("position", int, doc: "The line where the skip is inserted (zero-indexed).", required: true),
    field("length", int, doc: "The number of lines of the skip.", default: 1, named: false),
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

/// A single highlighted line, see the `highlighted-lines` field.
/// Can be constructed as `highlighted-line(line)`, `highlighted-line(line, color)`,
/// or cast from an integer or an array of the form `(line, color)`.
#let highlighted-line = e.types.declare(
  "highlighted-line",
  prefix: __codly-prefix,
  doc: "A line to be highlighted, with an optional custom highlight color.",
  fields: (
    field("line", int, doc: "The line number to highlight (one-indexed, as shown in the document).", required: true),
    field("color", types.option(types.paint), doc: "The highlight color of the line, defaults to `codly-highlight`'s `fill`.", default: none, named: false),
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

/// A single line of a codly code block. Takes over the line-level styling
/// arguments of `codly` (`radius`, `inset`, `fill`, `zebra-fill`, `stroke`).
#let codly-line = e.element.declare(
  "codly-line",
  prefix: __codly-prefix,
  doc: "A single line of a codly code block.",
  display: it => it.body,
  fields: (
    field("body", types.option(content), doc: "The content of the line.", required: true),
    field("radius", types.option(length), doc: __doc("radius"), default: __default("radius")),
    field("inset", types.option(types.union(length, dictionary)), doc: __doc("inset"), default: __default("inset")),
    field("fill", types.option(types.paint), doc: __doc("fill"), default: __default("fill")),
    field("zebra-fill", types.option(types.paint), doc: __doc("zebra-fill"), default: __default("zebra-fill")),
    field("stroke", types.option(stroke), doc: __doc("stroke"), default: __default("stroke")),
  )
)

/// The header of a codly code block. Takes over the `header-` prefixed
/// arguments of `codly`.
#let codly-header = e.element.declare(
  "codly-header",
  prefix: __codly-prefix,
  doc: "The header of a codly code block.",
  display: __codly-header-show,
  fields: (
    field("body", types.option(content), doc: __doc("header"), required: true),
    field("repeat", types.option(bool), doc: __doc("header-repeat"), default: __default("header-repeat")),

    // Replaces the old cell-args
    field("align", types.option(alignment), doc: "todo", default: center + horizon),
    field("breakable", types.option(types.union(bool, auto)), doc: "todo", default: auto),
    field("inset", types.option(types.union(length, dictionary, auto)), doc: "todo", default: auto),
    field("fill", types.option(types.union(types.paint, auto)), doc: "todo", default: auto),
    field("stroke", types.option(types.union(stroke, auto)), doc: "todo", default: auto),
  )
)

/// The footer of a codly code block. Takes over the `footer-` prefixed
/// arguments of `codly`.
#let codly-footer = e.element.declare(
  "codly-footer",
  prefix: __codly-prefix,
  doc: "The footer of a codly code block.",
  display: it => it.body,
  fields: (
    field("body", types.option(content), doc: __doc("footer"), required: true),
    field("repeat", types.option(bool), doc: __doc("footer-repeat"), default: __default("footer-repeat")),

    // Replaces the old cell-args
    field("align", types.option(alignment), doc: "todo", default: center + horizon),
    field("breakable", types.option(types.union(bool, auto)), doc: "todo", default: auto),
    field("inset", types.option(types.union(length, dictionary, auto)), doc: "todo", default: auto),
    field("fill", types.option(types.union(types.paint, auto)), doc: "todo", default: auto),
    field("stroke", types.option(types.union(stroke, auto)), doc: "todo", default: auto),
  )
)

/// The language badge of a codly code block. Takes over the `lang-` prefixed
/// arguments of `codly`, as well as `display-name` and `display-icon`.
#let codly-lang = e.element.declare(
  "codly-lang",
  prefix: __codly-prefix,
  doc: "The language badge of a codly code block.",
  display: __codly-lang-show,
  fields: (
    field("body", str, doc: "The language key, e.g. \"py\".", required: true),
    field("languages", types.option(types.dict(language)), doc: __doc("languages"), default: __default("languages")),
    field("default-color", types.option(types.paint), doc: __doc("default-color"), default: __default("default-color")),
    field("inset", types.option(types.union(length, dictionary)), doc: __doc("lang-inset"), default: __default("lang-inset")),
    field("outset", types.option(dictionary), doc: __doc("lang-outset"), default: __default("lang-outset")),
    field("radius", types.option(length), doc: __doc("lang-radius"), default: __default("lang-radius")),
    field("stroke", types.option(types.union(stroke, function)), doc: __doc("lang-stroke"), default: __default("lang-stroke")),
    field("fill", types.option(types.union(types.paint, function)), doc: __doc("lang-fill"), default: __default("lang-fill")),
    field("format", types.option(types.union(type(auto), function)), doc: __doc("lang-format"), default: __default("lang-format")),
    field("display-name", types.option(bool), doc: __doc("display-name"), default: __default("display-name")),
    field("display-icon", types.option(bool), doc: __doc("display-icon"), default: __default("display-icon")),
  )
)

/// A single highlight within a codly code block. Takes over the `highlight-`
/// prefixed arguments of `codly`.
#let codly-highlight = e.element.declare(
  "codly-highlight",
  prefix: __codly-prefix,
  doc: "A highlight over part of a line of a codly code block.",
  display: it => it.body,
  fields: (
    field("body", types.option(content), doc: "The highlighted content.", required: true),
    field("radius", types.option(length), doc: __doc("highlight-radius"), default: __default("highlight-radius")),
    field("fill", types.option(function), doc: __doc("highlight-fill"), default: __default("highlight-fill")),
    field("stroke", types.option(types.union(stroke, function)), doc: __doc("highlight-stroke"), default: __default("highlight-stroke")),
    field("inset", types.option(types.union(length, dictionary)), doc: __doc("highlight-inset"), default: __default("highlight-inset")),
    field("outset", types.option(types.union(length, dictionary)), doc: __doc("highlight-outset"), default: __default("highlight-outset")),
    field("clip", types.option(bool), doc: __doc("highlight-clip"), default: __default("highlight-clip")),
  )
)

/// A single annotation of a codly code block. Takes over the `annotation-`
/// prefixed arguments of `codly`.
#let codly-annotation = e.element.declare(
  "codly-annotation",
  prefix: __codly-prefix,
  doc: "An annotation displayed on the right side of a codly code block.",
  display: it => it.body,
  fields: (
    field("body", types.option(content), doc: "The content of the annotation.", required: true),
    field("format", types.option(function), doc: __doc("annotation-format"), default: __default("annotation-format")),
  )
)

/// A reference to a highlight or annotation of a codly code block. Takes over
/// the `reference-` prefixed arguments of `codly`.
#let codly-ref = e.element.declare(
  "codly-ref",
  prefix: __codly-prefix,
  doc: "A reference to a highlight or annotation of a codly code block.",
  display: it => it.body,
  fields: (
    field("body", types.option(content), doc: "The content of the reference.", required: true),
    field("by", types.option(types.union("line", "item")), doc: __doc("reference-by"), default: __default("reference-by")),
    field("sep", types.option(types.union(str, content)), doc: __doc("reference-sep"), default: __default("reference-sep")),
    field("number-format", types.option(function), doc: __doc("reference-number-format"), default: __default("reference-number-format")),
  )
)

/// A line number of a codly code block. Takes over the `number-` prefixed
/// arguments of `codly`.
#let codly-number = e.element.declare(
  "codly-number",
  prefix: __codly-prefix,
  doc: "A line number of a codly code block.",
  display: it => it.body,
  fields: (
    field("body", types.union(int, content), doc: "The line number content.", required: true),
    field("align", types.option(alignment), doc: __doc("number-align"), default: __default("number-align")),
    field("placement", types.option(types.union("inside", "outside")), doc: __doc("number-placement"), default: __default("number-placement")),
  )
)

#let codly = e.element.declare(
  "codly",
  prefix: __codly-prefix,
  doc: "Codly is a library that enhances the way you write code blocks in Typst.",
  display: it => {
    if not it.enabled {
      return it.body
    }

    show raw.where(block: true): r => __codly-show(r, it, codly-line, codly-lang, codly-header, codly-number, codly-annotation)
    
    it.body
  },
  fields: (
    field("body", types.option(content), doc: "The row block to style", required: true),
    field("alias", types.option(str), doc: "Whether this is an already aliased block", required: false, default: none),
    field("enabled", types.option(bool), doc: __doc("enabled"), default: __default("enabled")),
    field("number-enabled", types.option(bool), doc: "todo", default: true),
    field("offset", types.option(int), doc: __doc("offset"), default: __default("offset")),
    field("offset-from", types.option(label), doc: __doc("offset-from"), default: __default("offset-from")),
    field("range", types.option(range), doc: __doc("range"), default: __default("range"), folds: false),
    field("ranges", types.option(types.array(range)), doc: __doc("ranges"), default: __default("ranges"), folds: false),
    field("smart-skip", types.option(smart-skip), doc: __doc("smart-skip"), default: __default("smart-skip"), folds: false),
    field("aliases", types.option(dictionary), doc: __doc("aliases"), default: __default("aliases")),
    field("smart-indent", types.option(bool), doc: __doc("smart-indent"), default: __default("smart-indent")),
    field("skip-last-empty", types.option(bool), doc: __doc("skip-last-empty"), default: __default("skip-last-empty")),
    field("breakable", types.option(bool), doc: __doc("breakable"), default: __default("breakable")),
    field("skips", types.option(types.array(skip)), doc: __doc("skips"), default: __default("skips"), folds: false),
    field("skip-line", types.option(content), doc: __doc("skip-line"), default: __default("skip-line")),
    field("skip-number", types.option(content), doc: __doc("skip-number"), default: __default("skip-number")),
    field("annotations", types.option(types.array(annotation)), doc: __doc("annotations"), default: __default("annotations"), folds: false),
    field("highlighted", types.option(types.array(highlighted-line)), doc: __doc("highlighted-lines"), default: __default("highlighted-lines"), folds: false),
    field("highlights", types.option(types.array(highlight)), doc: __doc("highlights"), default: __default("highlights"), folds: false),
    field("header", types.option(content), doc: __doc("header"), default: __default("header")),
    field("footer", types.option(content), doc: __doc("footer"), default: __default("footer")),
    field("radius", types.option(length), doc: __doc("radius"), default: __default("radius")),
  )
)

#let codly-set(..args) = e.set_(codly, ..args)
#let codly-show(it, ..args) = e.show_(codly, it, ..args)
#let codly-selector(..args) = e.selector(codly, ..args)