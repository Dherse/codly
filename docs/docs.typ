#import "@preview/gentle-clues:1.0.0": *
#import "orly.typ": orly
#import "../args.typ": *
#import "../codly.typ": codly, codly-init, codly-reset, no-codly, codly-enable, codly-disable, codly-range, codly-offset, local, codly-skip

#show: codly-init
#show raw.where(block: false): set raw(lang: "typc")
#show raw.where(block: false): box.with(
  fill: luma(240),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)

#let img = image("typst-small.png", height: 0.8em)

// Start with a cover page
#orly(
    color: rgb("#85144b"),
    title: "Codly v1.1.0 manual",
    top-text: "Always start a new Typst project by importing codly",
    subtitle: "Your code blocks on steroids",
    pic: "/docs/codly.png",
    signature: "Dherse"
)

#let args = json("../args.json")

#let codly-args = arguments(
  header-cell-args: (align: center, ),
  header-transform: strong,
  enabled: true,
  languages: (
    typ: (
      name: "Typst",
      icon: box(img, baseline: 0.1em, inset: 0pt, outset: 0pt) + h(0.2em),
        color: rgb("#239DAD"),
    ),
    typc: (
      name: "Typst code",
      icon: box(img, baseline: 0.1em, inset: 0pt, outset: 0pt) + h(0.2em),
      color: rgb("#239DAD"),
    )
  ),
)
#codly(..codly-args)

#let example(raw, scale-factor: 100%) = context {
  codly(
    header: [ Example code ],
  )
  grid(
    columns: (1fr, )* 2,
    column-gutter: 0.32em,
    box(
      radius: 0.32em,
      inset: 0.32em,
      stroke: 1pt + luma(120),
      scale(scale-factor, reflow: true, raw)
    ),
    box(
      radius: 0.32em,
      width: 1fr,
      stroke: 1pt + luma(120),
      grid(
        columns: (1fr, ),
        inset: 0.32em,
        grid.header(grid.cell(align: center, strong[Rendered output])),
        {
          codly-reset()
          scale(scale-factor, reflow: true, eval(raw.text, scope: (codly: codly), mode: "markup"))
          codly-reset()
          codly(..codly-args)
        },
      )
    ),
  )
}

#set text(font: "Source Sans Pro", size: 10pt)
#set par(justify: true, spacing: 1.5em)
#counter(page).update(1)
#set heading(numbering: "1.1.")
#show link: underline
#show link: set text(fill: blue)
#set page(
  margin: (top: 0.5in, bottom: 0.4in, left: 0.75in, right: 0.75in),
  numbering: "1",
)

#codly(lang-format: none)

#outline(depth: 2, indent: true)

#pagebreak()

= Codly

Codly is a library that enhances the way you write code blocks in Typst. It provides a set of tools to help you manage your code blocks, highlights them, skip parts of them, and more. This manual will guide you through the different features of Codly, how to use them, and how to integrate them into your Typst projects.

#notify[If you find any issues with Codly, please report them on the GitHub repository: https://github.com/Dherse/codly.]

== Initialization

To start using Codly, you must first import it into your Typst project.

#example(
  ```typ
  #import "@preview/codly:1.0.0": *

  #show: codly-init
  ```
)

As you can see, this does nothing but initialize codly. You can also import it with a specific version, as shown in the example above. For the latest version, always refer to the #link("https://typst.app/universe/package/codly")[Typst Universe page].

From this point on, any code block that is included in your Typst project will be enhanced by Codly.

#example(
  ````typ
  ```
  Hello, world!
  ```
  ````
)


== Enabling and disabling codly

By defauly Codly will be enabled after initialization. However, disabling codly can be done using the #link(<codly-disable>)[`codly-disable`] function, the #link(<arg-enabled>)[`enabled`] argument of the `codly` function, or the #link(<no-codly>)[`no-codly`] function. To enable Codly again, use the #link(<codly-enable>)[`codly-enable`] function or by setting the #link(<arg-enabled>)[`enabled`] parameter again.

#pagebreak()

= A primer on Codly's show-rule like system
Codly uses a function called `codly` to create a kind of show-rule which you can use to configure how your code blocks are displayed. The `codly` function takes a set of arguments that define how the code block should be displayed. Here is the equivalent definition of the `codly` function:

```typc
let codly(
  enabled: true,
  offset: 0,
  range: none,
  languages: (:),
  display-name: true,
  display-icon: true,
  default-color: rgb("#283593"),
  radius: 0.32em,
  inset: 0.32em,
  fill: none,
  zebra-fill: luma(240),
  stroke: 1pt + luma(240),
  lang-inset: 0.32em,
  lang-outset: (x: 0.32em, y: 0pt),
  lang-radius: 0.32em,
  lang-stroke: (lang) => lang.color + 0.5pt,
  lang-fill: (lang) => lang.color.lighten(80%),
  lang-format: codly.default-language-block,
  number-format: (number) => [ #number ],
  number-align: left + horizon,
  smart-indent: false,
  annotations: none,
  annotation-format: numbering.with("(1)"),
  highlights: none,
  highlight-radius: 0.32em,
  highlight-fill: (color) => color.lighten(80%),
  highlight-stroke: (color) => 0.5pt + color,
  highlight-inset: 0.32em,
  reference-by: line,
  reference-sep: "-",
  reference-number-format: numbering.with("1"),
  header: none,
  header-repeat: false,
  header-transform: (x) => x,
  header-cell-args: (),
  footer: none,
  footer-repeat: false,
  footer-transform: (x) => x,
  footer-cell-args: (),
  breakable: false,
) = {}
```

The codly functions acts like a set-rule, this means that calling it will set the configuration for all code blocks that follow it, with the exception of a few arguments that are explicitly set for each code block. To perform changes locally, you can use the #link(<local>)[`local`] function, or set the arguments before the code block and reset them after to their previous values.

#let code-icon(icon, ..args) = text(
  font: "tabler-icons",
  fallback: false,
  weight: "regular",
  size: 1em,
  icon,
  ..args,
)
#let icon-ty = code-icon("\u{ea77}")
#let icon-val = code-icon("\u{f312}")
#let icon-con = code-icon("\u{eb20}")
#let icon-rst = code-icon("\u{fafd}")
#let icon-yes = code-icon("\u{ea5e}", fill: green, baseline: 0.15em)
#let icon-no = code-icon("\u{eb55}", fill: red, baseline: 0.15em)

#let ty_map(ty) = {
  if ty == "type(none)" {
    "none"
  } else {
    ty
  }
}
#let bool_yes_no(b) = {
  if b {
    icon-yes + [ yes]
  } else {
    icon-no + [ no]
  }
}

#let link-map(ty) = {
  if ty == "array" {
    "https://typst.app/docs/reference/foundations/array/"
  } else if ty == "string" or ty == "str" {
    "https://typst.app/docs/reference/foundations/str/"
  } else if ty == "dictionary" {
    "https://typst.app/docs/reference/foundations/dictionary/"
  } else if ty == "type(none)" or ty == "none" {
    "https://typst.app/docs/reference/foundations/none/"
  } else if ty == "type(auto)" {
    "https://typst.app/docs/reference/foundations/auto/"
  } else if ty == "content" {
    "https://typst.app/docs/reference/foundations/content/"
  } else if ty == "bool" {
    "https://typst.app/docs/reference/foundations/bool/"
  } else if ty == "arguments" {
    "https://typst.app/docs/reference/foundations/arguments/"
  } else if ty == "function" {
    "https://typst.app/docs/reference/foundations/function/"
  } else if ty == "color" {
    "https://typst.app/docs/reference/visualize/color/"
  } else if ty == "gradient" {
    "https://typst.app/docs/reference/visualize/gradient/"
  } else if ty == "pattern" {
    "https://typst.app/docs/reference/visualize/pattern/"
  } else if ty == "length" {
    "https://typst.app/docs/reference/layout/length/"
  } else if ty == "stroke" {
    "https://typst.app/docs/reference/visualize/stroke/"
  } else if ty == "alignment" {
    "https://typst.app/docs/reference/layout/alignment/"
  } else {
    panic("unknown type: " + ty)
  }
}
#let format-default(value) = {
  let e = eval(value)
  raw(lang: "typc", value)

  if type(e) == color {
    h(0.32em)
    box(height: 0.9em, width: 1.32em, fill: e, baseline: 0.1em)
  } else if type(e) == stroke {
    h(0.32em)
    box(width: 1.32em, height: 0.9em, baseline: 0.1em, stroke: e)
  }
}
#for (i, (key, arg)) in args.pairs().enumerate() {
  let header = heading(level: 2)[
    #arg.title (#raw(key))
  ]
  let label = label("arg-" + key)

  let tys = if type(arg.ty) == array {
    let long = arg.ty.len() > 2
    arg.ty.map(ty_map)
      .map((x) => (x, raw(lang: "typc", x)))
      .map(((key, value)) => link(link-map(key), value))
      .join(", ", last: if long { ", or " } else { " or "})
  } else {
    raw(lang: "typc", ty_map(arg.ty))
  }

  let paint = luma(0)
  let card = block(stroke: 1pt + paint, radius: 0.32em, table(
    columns: (auto, 1fr),
    stroke: none,
    align: (left + horizon, left + horizon),
    strong[ #icon-ty Type ],
    tys,
    table.hline(stroke: (thickness: 1pt, dash: "dashed", paint: paint)),
    strong[ #icon-val Default value],
    format-default(arg.default),
    table.hline(stroke: (thickness: 1pt, dash: "dashed", paint: paint)),
    strong[ #icon-con Contextual function ],
    bool_yes_no(arg.function),
    table.hline(stroke: (thickness: 1pt, dash: "dashed", paint: paint)),
    strong[ #icon-rst Automatically reset ],
    if "reset" in arg { bool_yes_no(arg.reset) } else { "no" },
  ))

  if calc.rem(i, 2) == 0 {
    pagebreak(weak: true)
  } else {
    align(center, line(length: 90%, stroke: (thickness: 1pt, dash: "dashed", paint: paint)))
  }

  [
    #header #label
    #card
    #eval(arg.description, mode: "markup", scope: (experiment: experiment))

    #if "experimental" in arg and arg.experimental {
      experiment[
        This feature should be considered experimental. Please report any issues you encounter on GitHub: https://github.com/Dherse/codly.
      ]
    }

    #if "example" in arg {
      [=== Example]
      example(
        raw(block: true, lang: "typ", arg.example),
        scale-factor: if "scale" in arg { eval(arg.scale) } else { 100% }
      )
    }
  ]
}

= Getting nice icons



= Other functions

== Reset (`codly-reset`) <codly-reset>
== Skip (`codly-skip`) <codly-skip>
== Range (`codly-range`) <codly-range>
== Offset (`codly-offset`) <codly-offset>
== Local (`local`) <local>
== No codly (`no-codly`) <no-codly>
== Enable (`codly-enable`) <codly-enable>
== Disable (`codly-disable`) <codly-disable>