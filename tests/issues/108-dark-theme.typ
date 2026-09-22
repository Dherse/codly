#import "../../codly.typ" as codly

#set page(width: 270pt, height: auto, margin: 5pt)

// #108: style the code rows, leaving badges and syntax token colors independent.
#{
  let foreground = rgb("#a9b1d6")
  let keyword = rgb("#bb9af7")
  let background = rgb("#1a1b26")
  set raw(theme: path("108-dark-theme.tmTheme"))
  show raw.line: set text(fill: foreground)
  show: codly.line-set_(fill: background, zebra-fill: none)
  show: codly.number-set_(placement: "outside", fill: none)
  show: codly.highlight-set_(fill: color => color)
  show: codly.lang-set_(languages: (py: (name: "Python", color: blue)))
  show text: it => context {
    if it.text.trim() != "" {
      [#metadata((it.text, text.fill))<dark-theme-text>#it]
    } else {
      it
    }
  }

  codly.new(raw("return identifier", lang: "py", block: true), highlights: (
    (line: 1, start: 7, end: 17, fill: rgb("#343b58")),
  ))

  // Explicitly styled names must remain customizable.
  {
    show: codly.lang-set_(languages: (
      py: (name: text(fill: white)[Custom], color: blue, fill: background),
    ))
    codly.new(raw("return identifier", lang: "py", block: true))
  }

  context {
    let colors = query(<dark-theme-text>).map(it => it.value)
    assert.eq(
      colors.filter(it => it.last() == foreground).map(it => it.first()).join(),
      "identifieridentifier",
    )
    assert.eq(colors.filter(it => it.first() == "return"), (
      ("return", keyword),
      ("return", keyword),
    ))
    assert.eq(colors.filter(it => it.first() == "Python"), (("Python", black),))
    assert.eq(colors.filter(it => it.first() == "Custom"), (("Custom", white),))
  }
}
