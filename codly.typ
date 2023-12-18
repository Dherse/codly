// Lets you set a line number offset.
#let codly-offset(offset: 0) = {
  state("codly-offset").update(offset)
}

// Lets you set a range of line numbers to highlight.
#let codly-range(
  start: 1,
  end: none,
) = {
  state("codly-range").update((start, end))
}

// Disables codly.
#let disable-codly() = {
  state("codly-config").update(none)
}

// Default language-block style
#let language-block(name, icon, color) = {
  let content = icon + name
  locate(loc => {
    let config = state("codly-config").at(loc)
    style(styles => {
      let height = measure(content, styles).height
      box(
        radius: config.radius,
        fill: color.lighten(60%),
        inset: config.padding,
        height: height + config.padding * 2,
        stroke: config.stroke-width + color,
        content,
      )
    })
  })
}

// Configures codly.
#let codly(
  // The list of languages, allows setting a display name and an icon,
  // it should be a dict of the form:
  //  `<language-name>: (name: <display-name>, icon: <icon-content>, color: <color>)`
  languages: (:),

  // Whether to display the language name.
  display-name: true,

  // Whether to display the language icon.
  display-icon: true,

  // The default color for a language not in the list.
  // Only used if `display-icon` or `display-name` is `true`.
  default-color: rgb("#283593"),

  // Radius of a code block.
  radius: 0.32em,

  // Padding of a code block.
  padding: 0.32em,

  // Fill color of lines.
  // If zebra color is enabled, this is just for odd lines.
  fill: white,

  // The zebra color to use or `none` to disable.
  zebra-color: luma(240),

  // The stroke width to use to surround the code block.
  // Set to `none` to disable.
  stroke-width: 0.1em,

  // The stroke color to use to surround the code block.
  stroke-color: luma(240),

  // The width of the numbers column.
  // If set to `none`, the numbers column will be disabled.
  width-numbers: 2em,

  // Format of the line numbers.
  // This is a function applied to the text of every line number.
  numbers-format: text,

  // A function that takes 3 positional parameters:
  // - name
  // - icon
  // - color
  // It returns the content for the language block.
  language-block: language-block,

  // Whether this code block is breakable.
  breakable: true,

  // Whether each raw line in a code block is breakable.
  // Setting this to true may cause problems when your raw block is split across pagebreaks,
  // so only change this setting if you're sure you need it.
  breakable-lines: false,
) = locate(loc => {
  let old = state("codly-config").at(loc);
  if old == none {
    state("codly-config").update((
      languages: languages,
      display-name: display-name,
      display-icon: display-icon,
      default-color: default-color,
      radius: radius,
      padding: padding,
      fill: fill,
      zebra-color: zebra-color,
      stroke-width: stroke-width,
      width-numbers: width-numbers,
      numbers-format: numbers-format,
      breakable: breakable,
      breakable-lines: breakable-lines,
      stroke-color: stroke-color,
      language-block: language-block
    ))
  } else {
    let folded_langs = old.languages;
    for (lang, def) in languages {
      folded_langs.insert(lang, def)
    }

    state("codly-config").update((
      languages: folded_langs,
      display-name: display-name,
      display-icon: display-icon,
      default-color: default-color,
      radius: radius,
      padding: padding,
      zebra-color: zebra-color,
      fill: fill,
      stroke-width: stroke-width,
      width-numbers: width-numbers,
      numbers-format: numbers-format,
      breakable: breakable,
      breakable-lines: breakable-lines,
      stroke-color: stroke-color,
      language-block: language-block
    ))
  }
})

#let codly-init(
  body,
) = {
  show raw.where(block: true): it => locate(loc => {
    let config = state("codly-config").at(loc)
    let range = state("codly-range").at(loc)
    let in_range(line) = {
      if range == none {
        true
      } else if range.at(1) == none {
        line >= range.at(0)
      } else {
        line >= range.at(0) and line <= range.at(1)
      }
    }
    if config == none {
      return it
    }
    let language_block = if config.display-name == false and config.display-icon == false {
      none
    } else if it.lang == none {
      none
    } else if it.lang in config.languages {
      let lang = config.languages.at(it.lang);
      let name = if config.display-name {
        lang.name
      } else {
        []
      }
      let icon = if config.display-icon {
        lang.icon
      } else {
        []
      }
      (config.language-block)(name, icon, lang.color)
    } else if config.display-name {
      (config.language-block)(it.lang, [], config.default-color)
    };

    let offset = state("codly-offset").at(loc);
    let start = if range == none { 1 } else { range.at(0) };
    let border(i, len) = {
      let end = if range == none { len } else if range.at(1) == none { len } else { range.at(1) };

      let stroke-width = if config.stroke-width == none { 0pt } else { config.stroke-width };
      let radii = (:)
      let stroke = (x: config.stroke-color + stroke-width)

      if i == start {
        radii.insert("top-left", config.radius)
        radii.insert("top-right", config.radius)
        stroke.insert("top", config.stroke-color + stroke-width)
      }

      if i == end {
        radii.insert("bottom-left", config.radius)
        radii.insert("bottom-right", config.radius)
        stroke.insert("bottom", config.stroke-color + stroke-width)
      }

      radii.insert("rest", 0pt)

      (radius: radii, stroke: stroke)
    }

    let width = if config.width-numbers == none { 0pt } else { config.width-numbers }
    show raw.line: it => if not in_range(it.number) {
      none
    } else {
      block(
        width: 100%,
        height: 1.2em + config.padding * 2,
        inset: (left: config.padding + width, top: config.padding + 0.1em, rest: config.padding),
        breakable: config.breakable-lines,
        fill: if config.zebra-color != none and calc.rem(it.number, 2) == 0 {
          config.zebra-color
        } else {
          none
        },
        radius: border(it.number, it.count).radius,
        stroke: border(it.number, it.count).stroke,
        {
          if it.number == start  {
            place(
              top + right,
              language_block,
              dy: -config.padding * 0.66666,
              dx: config.padding * 0.66666 - 0.1em,
            )
          }

          set par(justify: false)
          if config.width-numbers != none {
            place(
              horizon + left,
              dx: -config.width-numbers,
              (config.numbers-format)[#(offset + it.number)]
            )
          }
          it
        }
      )
    }

    let stroke = if config.stroke-width == 0pt or config.stroke-width == none {
      none
    } else {
      config.stroke-width + config.zebra-color
    };

    block(
      breakable: config.breakable,
      clip: false,
      width: 100%,
      radius: config.radius,
      fill: config.fill,
      stack(dir: ttb, ..it.lines)
    )

    codly-offset()
    codly-range(start: 1, end: none)
  })

  body
}
