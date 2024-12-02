#import "@preview/gentle-clues:1.0.0": *
#import "orly.typ": orly
#import "../args.typ": *
#import "../codly.typ": codly, codly-init, codly-reset, no-codly, codly-enable, codly-disable, codly-range, codly-offset, local, codly-skip, typst-icon

#show: codly-init
#show raw.where(block: false): set raw(lang: "typc")
#show raw.where(block: false): box.with(
  fill: luma(240),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)

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
  languages: typst-icon,
)
#codly(..codly-args)

#let example(raw, pre: none, scale-factor: 100%) = context {
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
      {
        pre
        raw
      }
    ),
    box(
      radius: 0.32em,
      width: 1fr,
      stroke: 1pt + luma(120),
      grid(
        columns: (1fr, ),
        inset: 0.32em,
        grid.header(
          grid.cell(
            inset: 0pt,
            align: center, box(
              fill: luma(240),
              stroke: 1pt + luma(120),
              inset: 0.32em,
              radius: (top-left: 0.32em, top-right: 0.32em),
              width: 1fr,
              strong[Rendered output]
            )
          )
        ),
        {
          codly-reset()
          eval(
            raw.text,
            scope: (codly: codly, local: local, no-codly: no-codly, codly-enable: codly-enable, codly-disable: codly-disable, codly-range: codly-range, codly-offset: codly-offset, codly-skip: codly-skip, codly-reset: codly-reset, typst-icon: typst-icon),
            mode: "markup"
          )
          codly-reset()
          codly(..codly-args)
        },
      )
    ),
  )
}

#set text(font: "Source Sans 3", size: 10pt)
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
  #import "@preview/codly:1.1.0": *

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

By default Codly will be enabled after initialization. However, disabling codly can be done using the #link(<codly-disable>)[`codly-disable`] function, the #link(<arg-enabled>)[`enabled`] argument of the `codly` function, or the #link(<no-codly>)[`no-codly`] function. To enable Codly again, use the #link(<codly-enable>)[`codly-enable`] function or by setting the #link(<arg-enabled>)[`enabled`] parameter again.

#pagebreak()

= A primer on Codly's show-rule like system
Codly uses a function called `codly` to create a kind of show-rule which you can use to configure how your code blocks are displayed. The `codly` function takes a set of arguments that define how the code block should be displayed. Here is the equivalent definition of the `codly` function:

```typc
let codly(
  enabled: true,
  offset: 0,
  offset-from: none,
  range: none,
  ranges: (),
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

#warning[
  Unlike regular set-rules in native Typst, there are two considerations:
  - The `codly` function uses states to store the configuration, this means that it is dependent on layout order for the order in which settings are applied.
  - The `codly` function is not local, it sets the configuration for all code blocks that follow it in layout order, unless overriden by another `codly` call. This means that you cannot use it to set the configuration for a specific code block. To perform this, use the #link(<local>)[`local`] function to set the configuration for a specific "section".
]

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
  } else if ty == "int" {
    "https://typst.app/docs/reference/foundations/int/"
  } else if ty == "label" {
    "https://typst.app/docs/reference/foundations/label/"
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
    link(link-map(arg.ty), raw(lang: "typc", ty_map(arg.ty)))
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
    if "reset" in arg { bool_yes_no(arg.reset) } else { bool_yes_no(false) },
  ))

  block(breakable: false, {
    [
      #header #label
      #card
      #eval(arg.description, mode: "markup", scope: (experiment: experiment, info: info, warning: warning))

      #if "experimental" in arg and arg.experimental {
        experiment[
          This feature should be considered experimental. Please report any issues you encounter on GitHub: https://github.com/Dherse/codly.
        ]
      }

      #if "example" in arg {
        [=== Example]
        example(
          raw(block: true, lang: "typ", arg.example)
        )
      }

      #if "examples" in arg {
        for ex in arg.examples {
          [=== Example: #ex.title]
          example(
            raw(block: true, lang: "typ", ex.code)
          )
        }
      }

      #if "post" in arg {
        eval(arg.post, mode: "markup", scope: (experiment: experiment, info: info, example: example))
      }
    ]
  })
}

#pagebreak(weak: true)
= Referencing code blocks, highlights, and annotations

This section of the documentation will detail how you can use codly to reference: lines, highlights, and annotations in your code blocks. To do this, here are the requirements that must be met *for each code block*:
#list(marker: sym.square)[
Numbering of figures must be turned on: `set figure(numbering: ...)`.
][
The code block must be contained within a raw figure: `figure(kind: raw)`.
][
The figure must have a label of its own: `figure(...)[...] <my-label>`.
]

== Shorthand line references
You can references lines directly, if you have set a label correctly, using the shorthand syntax `@my-label:1` to reference the second line (zero-based index) of the code block with the label `<my-label>`. It will always use the #link(<arg-reference-number-format>)[`reference-number-format`] argument of the `codly` function to format the line number.

#experiment[
  You might notice that the second reference in the example below is formatted like a #link("https://typst.app/docs/reference/model/link/")[`link`]. This is because it internally uses a `show ref: ..` show-rule which produces a link. This is a limitation of Typst and cannot be easily changed.
]

#example(
  ````typ
  #figure(
    caption: "A code block with a label"
  )[
    ```typ
    = Example
    *Hello, world!*
    ```
  ] <my-label>

  I can reference my code block: @my-label. But I can also reference a specific line of the label: @my-label:1.
  ````,
  pre: codly(
    ranges: ((1, 3), (8, 10)),
    skips: ((4, 0), )
  )
)

== Highlight references

You can also highlight by reference, to do this, you need to set a label for your highlight in the #link(<arg-highlights>)[`highlights`] argument of the `codly` function. You can then reference the highlight using the shorthand syntax `@my-highlight` to reference the highlight with the label `<my-highlight>`. There are two supported #link(<arg-reference-by>)[`reference-by`] modes:
- `"line"`: references the line of the highlight
- `"item"`: references the tag of the highlight, this requires that the `tag` be set *for each highlight*.

#example(
  ````typ
  #codly(
    highlights: ((line: 1, start: 2, end: 7, label: <hl-1>),
  ))
  #figure(
    caption: "A code block with a label"
  )[
    ```typ
    = Example
    *Hello, world!*
    ```
  ] <my-code>

  I can also reference a specific highlight by its label: @hl-1.
  ````,
  pre: codly(
    ranges: ((1, 3), (13, 13)),
    skips: ((4, 0), )
  )
)

And using #link(<arg-reference-by>)[`"item"`] mode:
#example(
  ````typ
  #codly(
    highlights: ((line: 1, start: 2, end: 7, label: <hl-2>, tag: [ Highlight ]), ),
    reference-by: "item",
  )
  #figure(
    caption: "A code block with a label"
  )[
    ```typ
    = Example
    *Hello, world!*
    ```
  ] <more-code>

  I can also reference a specific highlight by its label: @hl-2.
  ````,
  pre: codly(
    ranges: ((1, 4), (14, 14)),
    skips: ((5, 0), )
  )
)

#pagebreak(weak: true)
= Getting nice icons

This is a short, non-exhaustive guide on how to get nicer icons for the languages of your code blocks. In the documentation, codly makes use of tabler-icons to display the language icons. But a more general approach is the following:

+ Chose a font that contains icons, such as:
  - #link("https://tabler.io/icons")[Tabler Icons]
  - #link("https://fontawesome.com/")[Font Awesome]
  - #link("https://material.io/resources/icons/")[Material Icons]
  - Look on #link("https://fonts.google.com/")[Google Fonts] for more options
+ Download the font and put it in your project (if using the _CLI_, you need to set the `--font` argument)
+ Using your font selector, select the icon you wish to use
  - For example, the language icon in Tabler Icons is `ebbe` (the unicode value of the icon, which you can find in the documentation of the font)
  - Use the #link("https://typst.app/docs/reference/text/text/")[`text`] function to display the icon in your document by setting the font, size, and the unicode value of the icon:
  #codly(highlights: ((line: 0, start: 12, end: 25, tag: [ Font name ]), (line: 0, start: 43, end: 46, fill: green, tag: [ UTF-8 icon code])))
  ```typc
  text(font: "tabler-icons", size: 1em, "\u{ebbe}")
  ```
+ You can store it the `languages` argument of the `codly` function to use it for all code blocks in your document: #example(````typ
  #let icon = text(font: "tabler-icons", size: 1em, "\u{ebbe}")
  #codly(languages: (text: (icon: icon, name: "Text")))
  ```text
  Hello, world!
  ```
````)
+ Congrats, you now have fancy icons!
+ ...
+ But you can notice that the baseline of the icon is wrong, I find that this is generally the case with tabler, you can set the baseline to `0.1em` in the icon to fix it: #example(````typ
  #let icon = text(font: "tabler-icons", size: 1em, "\u{ebbe}", baseline: 0.1em)
  #codly(languages: (text: (icon: icon, name: "Text")))
  ```text
  Hello, world!
  ```
````)

== Typst language icon (`typst-icon`) <typst-icon>

Additionally, codly ships with language definitions for the Typst language. You can use the `typst-icon` function to get the Typst icon for your code blocks. This function takes no arguments and returns the proper settings for codly to use the Typst icon.

#info[You can use the `..` spread operator to spread it into your own `languages` dictionary.]

#example(````typ
  #codly(languages: typst-icon)
  ```typ
  = Here's a title
  Hello, world!
  ```
````)

#pagebreak(weak: true)
= Other functions

== Skip (`codly-skip`) <codly-skip>
Convenience function for setting the skips, see the #link(<arg-skips>)[`skips`] argument of the `codly` function.

== Range (`codly-range`) <codly-range>
Convenience function for setting the range, see the #link(<arg-range>)[`range`] argument of the `codly` function. If you provide more than one range, as a list of arguments, it will set the #link(<arg-ranges>)[`ranges`] argument instead.

With a single range:
#example(````typ
#codly-range(2, end: 2)
```py
def fib(n):
  if n <= 1:
      return n
  return fib(n - 1) + fib(n - 2)
fib(25)
```
````)

With more than one range:
#example(````typ
#codly-range(2, end: 2, (4, 5))
```py
def fib(n):
  if n <= 1:
      return n
  return fib(n - 1) + fib(n - 2)
fib(25)
```
````)

== Offset (`codly-offset`) <codly-offset>
Convenience function for setting the offset, see the #link(<arg-offset>)[`offset`] argument of the `codly` function.

#pagebreak(weak: true)
== Local (`local`) <local>

Codly provides a convenience function called `local` that allows you to locally override the global settings for a specific code block. This is useful when you want to apply a specific style to a code block without affecting the rest of the code blocks in your document. It works by overriding the default codly show rule locally with an override of the arguments by those you provide. It does not rely on states (much) and should no longer add layout passes to the rendering which could cause documents to not converge.

#warning[When using `nested: false` on your local states, the outermost local state will be overriden by the inner local state(s). This means that the inner local state will be the only one that is applied to the code block. And that any previous local states (in the same hierarchy) will be ignored for subsequent code blocks.]

#info[Once custom elements become available in Typst, and codly moves to using those and set rules, this limitation will be lifted and you will be able to use nested local states without performance impact.]

#example(````typ
*Global state with red color*
#codly(fill: red)
```typ
= Example
*Hello, World!*
```
*Locally set it to gray*
#local(
  fill: luma(240),
  ```typ
  = Example
  *Hello, World!*
  ```
)
* It's back to being red*
```typ
= Example
*Hello, World!*
```
````)

#pagebreak(weak: true)
=== Local state for per-language configuration

Additionally, local settings can be used to set per-language configuration using a show rule on your #link("https://typst.app/docs/reference/text/raw/")[`raw`] blocks. This can be done in one of two ways: by using a show rule on `raw.where(block: true, lang: "<lang>")` and calling the #link(<local>)[`local`] function, or by using the `codly` function. The main differentiators are that the `local` function is faster and does not rely on states, while the `codly` function is more flexible, but slower and *will also style all following blocks*, you must therefore manually reset the changes.

#experiment[
  This should work in most cases, but this feature should be considered experimental. Please report any issues you encounter on GitHub:  https://github.com/Dherse/codly.
]

#info[
  Note that you only want to do show rules on `raw` blocks where `block: true`, otherwise this will make your document slow.
]

#warning[
 If you use the `local` function in a show rule, nested `local` states *will not work* with the settings you have set! Use the `codly` method instead. If using the `codly` method, and you *must* manually reset the changed settings in the show rule!
]

#example(````typ
#show raw.where(block: true, lang: "rust"): local.with(
  number-format: numbering.with("I")
)

#show raw.where(block: true, lang: "py"): it => {
  codly(number-format: numbering.with("①"))
  it
  codly(number-format: numbering.with("1"))
}

*Numbered with Roman numerals*
```rust
fn main() {
  println!("Rust code has Roman numbers");
}

```
*Numbered with circled numbers*
```py
print("Python code has circled numbers")
```

*Override with local state*
#local(
  fill: blue.lighten(80%),
  ```py
  print("Python code is green")
  ```
)
````)

#pagebreak(weak: true)
=== Nested local state
Codly does support nested local state, the innermost local state will override the outermost local state. This allows you to have different styles for different parts of your code block. This function takes the same arguments as the `codly` function, but only the arguments that are different from the global settings need to be provided.

#warning[Nested local states can slow down documents significantly if over-used (explicitly set `nested: true`). Use them sparingly and only when necessary. Another solution is to use the normal `codly` function before and after your code block. You can also use the the argument `nested: false` on `local` to prevent nested local states, which significantly reduces the performance impact.]

#example(````typ
*Global state with red color*
#codly(fill: red)
```typ
= Example
*Hello, World!*
```
*Locally set it to blue*
#local(
  nested: true,
  fill: blue,
)[
  ```typ
  = Example
  *Hello, World!*
  ```
  *Now it's green:*
  #local(nested: true, fill: green)[
    ```typ
    = Example
    *Hello, World!*
    ```
  ]
  *Now its zebras are also blue:*
  #local(nested: true, zebra-fill: blue)[
    ```typ
    = Example
    *Hello, World!*
    ```
  ]

  *Back to blue:*
  ```typ
  = Example
  *Hello, World!*
  ```
]
*Back to red:*
```typ
= Example
*Hello, World!*
```
````)

#pagebreak(weak: true)
== No codly (`no-codly`) <no-codly>
This is a convenience function equivalent to `local(enabled: false, body)`.

#example(````typ
*Enabled codly*
```typ
= Example
*Hello, World!*
```

*Disabled codly*
#no-codly[
  ```typ
  = Example
  *Hello, World!*
  ```
]
````)

== Enable (`codly-enable`) <codly-enable>
Enables codly globally, equivalent to `codly(enabled: true)`.
#example(````typ
*Disabled codly*
#codly-disable()
```typ
= Example
*Hello, World!*
```
#codly-enable()
*Enabled codly*
```typ
= Example
*Hello, World!*
```
````)

== Disable (`codly-disable`) <codly-disable>
Disables codly globally, equivalent to `codly(enabled: false)`.
#example(````typ
*Enabled codly*
```typ
= Example
*Hello, World!*
```

*Disabled codly*
#codly-disable()
```typ
= Example
*Hello, World!*
```
````)

#pagebreak(weak: true)

== Reset (`codly-reset`) <codly-reset>
Resets all codly settings to their default values. This is useful when you want to reset the settings of a code block to the default values after applying local settings.

#example(````typ
*Global state with red color*
#codly(fill: red)
```typ
= Example
*Hello, World!*
```
*Reset it*
#codly-reset()
```typ
= Example
*Hello, World!*
```
````)

#pagebreak(weak: true)
= Codly performance