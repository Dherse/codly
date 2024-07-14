#import "args.typ": __codly-args, __codly-save, __codly-load

// Default language-block style
#let default-language-block(name, icon, color) = {
  let radius = (__codly-args.lang-radius.get)()
  let padding = (__codly-args.lang-inset.get)()

  let lang-stroke = (__codly-args.lang-stroke.get)()
  let lang-fill = (__codly-args.lang-fill.get)()

  let fill = if type(lang-fill) == function {
    (lang-fill)((name: name, icon: icon, color: color))
  } else {
    color
  }

  let stroke = if type(lang-stroke) == function {
    (lang-stroke)((name: name, icon: icon, color: color))
  } else {
    lang-stroke
  }

  box(
    radius: radius,
    fill: fill,
    inset: padding,
    stroke: stroke,
    outset: 0pt,
    icon + name,
  )
}

/// Lets you set a line number offset.
/// 
/// #pre-example()
/// #example(````
///  #codly-offset(offset: 25)
///  ```py
///  def fib(n):
///      if n <= 1:
///          return n
///      return fib(n - 1) + fib(n - 2)
///  fib(25)
///  ```
/// ````, mode: "markup", scale-preview: 100%)
#let codly-offset(offset: 0) = {
  (__codly-args.offset.update)(offset)
}

/// Lets you set a range of line numbers to highlight.
/// Similar to `codly(range: (start, end))`.
/// 
/// #pre-example()
/// #example(````
///  #codly-range(start: 2)
///  ```py
///  def fib(n):
///      if n <= 1:
///          return n
///      return fib(n - 1) + fib(n - 2)
///  fib(25)
///  ```
/// ````, mode: "markup", scale-preview: 100%)
#let codly-range(
  start: 1,
  end: none,
) = {
  (__codly-args.range.update)((start, end))
}

/// Disables codly.
/// 
/// #pre-example()
/// #example(````
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
/// 
///  #codly-disable()
///  *Disabled:*
///  ```
///  Hello, world!
///  ```
/// ````, mode: "markup", scale-preview: 100%)
#let codly-disable() = {
  (__codly-args.enabled.update)(false)
}

/// Enables codly.
/// 
/// #pre-example()
/// #example(````
///  #codly-disable()
///  *Disabled:*
///  ```
///  Hello, world!
///  ```
/// 
///  #codly-enable()
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
/// ````, mode: "markup", scale-preview: 100%)
#let codly-enable() = {
  (__codly-args.enabled.update)(true)
}

/// Disabled codly locally.
/// 
/// #pre-example()
/// #example(````
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
/// 
///  *Disabled:*
///  #no-codly(```
///  Hello, world!
///  ```)
/// ````, mode: "markup", scale-preview: 100%)
#let no-codly(body) = {
  (__codly-args.enabled.update)(false)
  body
  (__codly-args.enabled.update)(true)
}

/// Appends a skip to the list of skips.
/// 
/// #pre-example()
/// #example(````
///  #codly-skip(4, 32)
///  ```
///  Hello, world!
///  Goodbye, world!
///  ```
/// ````, mode: "markup", scale-preview: 100%)
#let codly-skip(
  position,
  length,
) = {
  state("codly-skips", ()).update((skips) => {
    if skips == none {
      skips = ()
    }

    skips.push((position, length))
    skips
  })
}


/// Configures codly.
/// Is used in a similar way as `set` rules. You can imagine the following:
/// ```typc
/// // This is a representation of the actual code.
/// // The actual code behave like a set rule that uses `state`.
/// let codly(
///    enabled: true,
///    offset: 0,
///    range: none,
///    languages: (:),
///    display-name: true,
///    display-icon: true,
///    default-color: rgb("#283593"),
///    radius: 0.32em,
///    inset: 0.32em,
///    fill: none,
///    zebra-fill: luma(240),
///    stroke: 1pt + luma(240),
///    lang-inset: 0.32em,
///    lang-outset: (x: 0.32em, y: 0pt),
///    lang-radius: 0.32em,
///    lang-stroke: (lang) => lang.color + 0.5pt,
///    lang-fill: (lang) => lang.color.lighten(80%),
///    lang-formatter: codly.default-language-block,
///    number-format: (number) => [ #number ],
///    number-align: left + horizon,
///    breakable: false,
/// ) = {}
/// ```
/// 
/// Each argument is explained below.
/// 
/// == Display style
/// Codly displays your code in three sections:
/// - The line number, if `number-format` is not `none`
/// - The language block, with a fill and a stroke, only appears on the first line
/// - The code itself with optional zebra striping
/// 
/// The block as a whole is surrounded by a stroke.
/// 
/// #align(center, block(width: 80%)[
/// #codly(number-format: none)
/// ```
/// |----------------------------------------------------------------|
/// |1 | [line, zebra]                                | [lang block] |
/// |2 | [line, non-zebra]                                           |
/// |3 | [line, zebra]                                               |
/// |4 | [line, non-zebra]                                           |
/// |----------------------------------------------------------------|
/// ```
/// ])
/// 
/// == Note about arguments:
/// Some arguments can be a function that takes no arguments and returns the value.
/// They are called within a `context` that provides the current location.
/// They can be used to have more dynamic control over the value, without the need
/// for sometimes slow state updates.
///
/// == Enabled (`enabled`)
/// Whether codly is enabled or not.
/// If it is disabled, the code block will be displayed as a normal code block,
/// without any additional codly-specific formatting.
/// 
/// This is useful if you want to disable codly for a specific block.
/// 
/// You can also disable codly locally using the @@no-codly() function, or disable it
/// and enable it again using the @@codly-disable() and @@codly-enable() functions.
/// 
/// - *Default*: `true`
/// - *Type*: `bool`
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(enabled: true)
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
/// 
///  #codly(enabled: false)
///  *Disabled:*
///  ```
///  Hello, world!
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Offset (`offset`)
/// The offset to apply to line numbers.
/// 
/// Note that the offset gets reset automatically after every code block.
/// 
/// - *Default*: `0`
/// - *Type*: `int`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(offset: 0)
///  *No offset:*
///  ```
///  Hello, world!
///  ```
/// 
///  #codly(offset: 5)
///  *With offset:*
///  ```
///  Hello, world!
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Range (`range`)
/// The range of line numbers to display.
/// 
/// Note that the range gets reset automatically after every code block.
/// 
/// The same behavior can be achieved using the @@codly-range() function.
/// 
/// - *Default*: `none`
/// - *Type*: `(int, int)` or `none`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(range: (2, 4))
///  ```py
///  def fib(n):
///      if n <= 1:
///          return n
///      return fib(n - 1) + fib(n - 2)
///  fib(25)
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Skips (`skips`)
/// Insert a skip at the specified line numbers, setting its offset to the
/// length of the skip. The skip is formatted using `skip-number`
/// and `skip-line`.
/// 
/// Each skip is an array with two values: the position and length of the skip.
/// 
/// Note that the skips gets reset automatically after every code block.
/// 
/// The same behavior can be achieved using the @@codly-skip() function, which
/// appends one or more skips to the list of skips.
/// 
/// - *Default*: `()`
/// - *Type*: `array` or `none`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(skips: ((4, 32), ))
///  ```py
///  def fib(n):
///      if n <= 1:
///          return n
///      return fib(n - 1) + fib(n - 2)
///  fib(25)
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Skip number (`skip-number`)
/// Sets the content with which the line number columns is filled when a skip is
/// encountered. If line numbers are disabled, this has no effect.
/// 
/// == Skip line (`skip-line`)
/// Sets the content with which the line columns is filled when a skip is
/// encountered.
/// 
/// == Languages (`languages`)
/// The language definitions to use for language block formatting.
/// 
/// It is defined as a dictionary where the keys are the language names  and
/// each value is another dictionary containing the following keys:
/// - `name`: the "pretty" name of the language as a content/showable value
/// - `color`: the color of the language, if omitted uses the default color
/// - `icon`: the icon of the language, if omitted no icon is shown
/// 
/// Alternatively, the value can be a string, in which case it is used as the
/// name of the language. And no icon is shown and the default color is used.
/// 
/// If an entry is missing, and language blocks are enabled, will show
/// the "un-prettified" language name, with the default color.
/// 
/// - *Default*: `(:)`
/// - *Type*: `dict`
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(
///    languages: (
///      py: (name: "Python", color: red, icon: "🐍")
///    )
///  )
///  ```py
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Display name (`display-name`)
/// 
/// Whether to display the name of the language in the language block.
/// This only applies if you're using the default language block formatter.
/// 
/// - *Default*: `true`
/// - *Type*: `bool`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(display-name: false)
///  ```py
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Display icon (`display-icon`)
/// Whether to display the icon of the language in the language block.
/// This only applies if you're using the default language block formatter.
/// 
/// - *Default*: `true`
/// - *Type*: `bool`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(
///    display-icon: false,
///    languages: (
///      py: (name: "Python", color: red, icon: "🐍")
///    )
///  )
///  ```py
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Default color (`default-color`)
/// The default color to use for language blocks.
/// 
/// This only applies if you're using the default language block formatter.
/// Also note that it is also passed as a named argument to the language
/// block formatter if you've defined your own.
///  
/// - *Default*: `rgb("#283593")` (a shade of blue)
/// - *Type*: `color`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(default-color: orange)
///  ```py
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Radius (`radius`)
/// The radius of the border of the code block.
/// 
/// - *Default*: `0.32em`
/// - *Type*: `length`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(radius: 0pt)
///  ```
///  print('Hello, world!')
///  ```
///  #codly(radius: 20pt)
///  ```
///  print('Hello, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Inset (`inset`)
/// The inset of the code block.
/// 
/// - *Default*: `0.32em`
/// - *Type*: `length`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(inset: 10pt)
///  ```
///  print('Hello, world!')
///  ```
///  #codly(inset: 0pt)
///  ```
///  print('Hello, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Fill (`fill`)
/// The fill of the code block when not zebra-striped.
/// 
/// - *Default*: `none`
/// - *Type*: `none`, `color`, `gradient`, or `pattern`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(
///    fill: gradient.linear(..color.map.flare),
///  )
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Zebra color (`zebra-fill`)
/// The fill of the code block when zebra-striped, `none` to disable zebra-striping.
/// 
/// #pre-example()
/// #example(````
///  #codly(
///    zebra-fill: gradient.linear(..color.map.flare),
///  )
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// - *Default*: `none`
/// - *Type*: `none`, `color`, `gradient`, or `pattern`
/// - *Can be a contextual function*: yes
/// 
/// == Stroke (`stroke`)
/// The stroke of the code block.
/// 
/// - *Default*: `1pt + luma(240)`
/// - *Type*: `none` or `stroke`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(
///    stroke: 1pt + gradient.linear(..color.map.flare),
///  )
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block inset (`lang-inset`)
/// The inset of the language block.
/// 
/// This only applies if you're using the default language block formatter.
/// 
/// - *Default*: `0.32em`
/// - *Type*: `length`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-inset: 5pt)
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block outset (`lang-outset`)
/// The X and Y outset of the language block, applied as a `dx` and `dy` during
/// the `place` operation.
/// 
/// This applies in every case, whether or not you're using the default language
/// block formatter.
/// 
/// The default value is chosen to get rid of the `inset` applied to each line.
/// 
/// - *Default*: `(x: 0.32em, y: 0pt)`
/// - *Type*: `dict`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-outset: (x: -10pt, y: 5pt))
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block radius (`lang-radius`)
/// The radius of the language block.
/// 
/// - *Default*: `0.32em`
/// - *Type*: `length`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-radius: 10pt)
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block stroke (`lang-stroke`)
/// The stroke of the language block.
/// 
/// - *Default*: `none`
/// - *Type*: `none`, `stroke`, or a function that takes in the language dict or none
/// (see argument `languages`) and returns a stroke.
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-stroke: 1pt + red)
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
///  #codly(lang-stroke: (lang) => 2pt + lang.color)
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block fill (`lang-fill`)
/// The fill of the language block.
/// 
/// - *Default*: `none`
/// - *Type*: `none`, `color`, `gradient`, `pattern`, or a function that takes in
/// the language dict or none (see argument `languages`) and returns a fill.
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-fill: red)
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
///  #codly(lang-fill: (lang) => lang.color.lighten(40%))
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block formatter (`lang-formatter`)
/// The formatter for the language block.
/// 
/// A value of `none` will use the default language block formatter.
/// To disable the language block, set `display-icon` and `display-name` to `false`.
/// Or set `lang-formatter` to `(..) => none`.
/// 
/// - *Default*: `codly.default-language-block`
/// - *Type*: `function`
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-formatter: (..) => [ No! ])
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Line number formatter (`number-format`)
/// The formatter for line numbers.
/// 
/// - *Default*: `(line) => str(line)`
/// - *Type*: `function`
/// - *Can be a contextual function*: false
/// 
/// #pre-example()
/// #example(````
///  #codly(number-format: (n) => numbering("I.", n))
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Line number alignment (`number-align`)
/// The alignment of the line numbers.
/// 
/// - *Default*: `left + horizon`
/// - *Type*: `top`, `horizon`, or `bottom`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(number-align: right + horizon)
///  ```py
///  # Iterative Fibonacci
///  # As opposed to the recursive
///  # version
///  def fib(n):
///    if n <= 1:
///      return n
///    last, current = 0, 1
///    for _ in range(2, n + 1):
///      last, current = current, last + current
///    return current
///  print(fib(25))
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Smart indentation (`smart-indent`)
/// Whether to use smart indentation, which will check for indentation on a line
/// and use a bigger left side inset instead of spaces. This allows for linebreaks
/// to continue at the same level of indentation. This is off by default
/// since it is slower.
/// 
/// - *Default*: `false`
/// - *Type*: `bool`
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(smart-indent: true)
///  ```py
///  def fib(n):
///    if n <= 1:
///      return n
///    else:
///      return (fib(n - 1) + fib(n - 2))
///  print(fib(25))
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Breakable (`breakable`)
/// Whether the code block is breakable.
/// 
/// - *Default*: `false`
/// - *Type*: `bool`
/// - *Can be a contextual function*: no
#let codly(
  ..args,
) = {
  let pos = args.named()

  if args.pos().len() > 0 {
    panic("codly: no positional arguments are allowed")
  }

  for (key, arg) in __codly-args {
    if key in pos {
      // Remove the argument from the list.
      let i = pos.remove(key)

      // Update the state.
      (arg.update)(i)
    }
  }

  // Special code that checks that languages are valid.
  context {
    let languages = (__codly-args.languages.get)()
    for (key, lang) in languages {
      if type(lang) != dictionary and type(lang) != str {
        panic("codly: language " + key + " is not a dictionary")
      }

      if type(lang) == dictionary and "name" not in lang {
        panic("codly: language " + key + " is missing a name")
      }
    }
  }

  if pos.len() > 0 {
    panic("codly: unknown arguments: " + pos.keys().join(", "))
  }
}

// Resets the codly state to its default values.
// This is useful if you want to reset the state of codly to its default values.
// 
// Note that this is mostly intended for testing purposes.
#let codly-reset() = {
  for (_, arg) in __codly-args {
    (arg.reset)()
  }
}

/// Initializes the codly show rule.
///
/// ```typ
/// #show: codly-init
/// ```
#let codly-init(
  body,
) = {
  show raw.where(block: true): it => context {
    let indent_regex = regex("\\s*")
    let args = __codly-args
    let range = (args.range.get)()
    let in_range(line) = {
      if range == none {
        true
      } else if range.at(1) == none {
        line >= range.at(0)
      } else {
        line >= range.at(0) and line <= range.at(1)
      }
    }
    if (args.enabled.get)() != true {
      return it
    }
  
    let languages = (args.languages.get)()
    let display-names = (args.display-name.get)()
    let display-icons = (args.display-icon.get)()
    let lang-outset = (args.lang-outset.get)()
    let language-block = {
      let fn = (args.lang-formatter.get)()
      if fn == none {
        default-language-block
      } else {
        fn
      }
    }
    let default-color = (args.default-color.get)()
    let radius = (args.radius.get)()
    let offset = (args.offset.get)()
    let stroke = (args.stroke.get)()
    let zebra-color = (args.zebra-fill.get)()
    let numbers-format = (args.number-format.get)()
    let numbers-alignment = (args.number-align.get)()
    let padding = (args.inset.get)()
    let breakable = (args.breakable.get)()
    let fill = (args.fill.get)()
    let smart-indent = (args.smart-indent.get)()
    let skips = {
      let skips = (args.skips.get)()
      if skips == none {
        ()
      } else {
        skips.sorted(key: (x) => x.at(0)).dedup()
      }
    }
    let skip-line = (args.skip-line.get)()
    let skip-number = (args.skip-number.get)()

    let start = if range == none { 1 } else { range.at(0) };

    let items = ()
    let height = measure[1].height
    for (i, line) in it.lines.enumerate() {
      // Try and look for a skip
      let skip = skips.at(0, default: none)
      if skip != none and i == skip.at(0) {
        items.push(skip-number)
        items.push(skip-line)
        // Advance the offset.
        offset += skip.at(1)
      }

      if not in_range(line.number) {
        continue
      }

      // Always push the formatted line number
      let l = line.body

      // Must be done before the smart indentation code.
      // Otherwise it results in two paragraphs.
      if numbers-format != none {
        items.push(numbers-format(line.number + offset))
      } else {
        l += box(height: height, width: 0pt)
      }

      // Smart indentation code.
      if smart-indent and l.has("children") {
        // Check the indentation of the line by taking l,
        // and checking for the first element in the sequence.
        let first = l.children.at(0, default: none)
        if first != none and first.has("text") {
          let match = first.text.match(indent_regex)

          // Ensure there is a match and it starts at the beginning of the line.
          if match != none and match.start == 0 {
            // Calculate the indentation.
            let indent = match.end - match.start

            // Then measure the necessary indent.
            let indent = first.text.slice(match.start, match.end)
            let width = measure([#indent]).width

            // We add the indentation to the line.
            l = {
              set par(hanging-indent: width)
              l
            }
          }
        }
      }

      if line.number != start or (display-names != true and display-icons != true) {
        items.push(l)
        continue
      } else if it.lang == none {
        items.push(l)
        continue
      }
      
      // The language block (icon + name)
      let language-block = if it.lang in languages {
        let lang = languages.at(it.lang);
        let name = if type(lang) == str {
          lang
        } else if display-names and "name" in lang  {
          lang.name
        } else {
          []
        }
        let icon = if display-icons and "icon" in lang {
          lang.icon
        } else {
          []
        }
        let color = if "color" in lang {
          lang.color
        } else {
          default-color
        }
        (language-block)(name, icon, color)
      } else if display-names {
        (language-block)(it.lang, [], default-color)
      }

      // Push the line and the language block in a grid for alignment
      let lb = measure(language-block);
      items.push(grid(
        columns: (1fr, lb.width + 2 * padding),
        l,
        place(
          right + horizon,
          dx: lang-outset.x,
          dy: lang-outset.y,
          language-block
        ),
      ))
    }

    // If the fill or zebra color is a gradient, we will draw it on a separate layer.
    let is-complex-fill = ((type(fill) != color and fill != none) 
        or (type(zebra-color) != color and zebra-color != none))

    block(
      breakable: breakable,
      clip: true,
      width: 100%,
      radius: radius,
      stroke: stroke,
      {
        if is-complex-fill {
          // We use place to draw the fill on a separate layer.
          place(
            grid(
              columns: (1fr, ),
              stroke: none,
              inset: padding * 1.5,
              fill: (x, y) => if zebra-color != none and calc.rem(y, 2) == 0 {
                zebra-color
              } else {
                fill
              },
              ..it.lines.map((line) => hide(line))
            )
          )
        }
        if numbers-format != none {
          grid(
            columns: (auto, 1fr),
            inset: padding * 1.5,
            stroke: none,
            align: (numbers-alignment, left + horizon),
            fill: if is-complex-fill {
              none
            } else {
              (x, y) => if zebra-color != none and calc.rem(y, 2) == 0 {
                zebra-color
              } else {
                fill
              }
            },
            ..items,
          )
        } else {
          grid(
            columns: (1fr, ),
            inset: padding * 1.5,
            stroke: none,
            align: (numbers-alignment, left + horizon),
            fill: (x, y) => if zebra-color != none and calc.rem(y, 2) == 0 {
              zebra-color
            } else {
              fill
            },
            ..items,
          )
        }
      }
    )

    codly-offset()
    codly-range(start: 1, end: none)
    state("codly-skips").update((_) => ())
  }

  body
}

/// Allows setting codly setting locally.
/// Anything that happens inside the block will have the settings applied only to it.
/// The pre-existing settings will be restored after the block. This is useful
/// if you want to apply settings to a specific block only.
/// 
/// #pre-example()
/// #example(`````
///  *Special:*
///  #local(default-color: red)[
///    ```
///    Hello, world!
///    ```
///  ]
/// 
///  *Normal:*
///  ```
///  Hello, world!
///  ```
/// `````, mode: "markup", scale-preview: 100%)
#let local(body, ..args) = context {
  let old = __codly-save()
  codly(..args)
  body
  __codly-load(old)
}