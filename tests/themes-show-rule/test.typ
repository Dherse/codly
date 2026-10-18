#import "../../codly.typ" as codly

#set page(width: 300pt, height: auto, margin: 8pt)
#show: codly.theme("dark")

#let sample(key, body) = {
  show text: it => context {
    if it.text.contains("return") {
      [#metadata((key, text.fill))<keyword>#metadata(text.size)<code-size>]
    }
    it
  }
  show: codly.header-show_(it => [#metadata(key)<header>#it])
  body
}

#sample("show-rule")[
  #show raw.where(block: true): codly.new
  ```py
  return identifier
  ```
]
#sample("raw", codly.new(raw("return identifier", block: true, lang: "py")))
#sample("string", codly.new("return identifier", lang: "py"))

// Explicitly disabled or custom highlighting survives the show-rule path.
#sample("none")[
  #show raw.where(block: true): codly.new
  #raw("return identifier", block: true, lang: "py", theme: none)
]
#sample("custom")[
  #show raw.where(block: true): codly.new
  #raw(
    "return identifier",
    block: true,
    lang: "py",
    theme: path("../issues/108-dark-theme.tmTheme"),
  )
]

#context {
  assert.eq(query(<keyword>).map(it => it.value), (
    ("show-rule", rgb("c586c0")),
    ("raw", rgb("c586c0")),
    ("string", rgb("c586c0")),
    ("none", rgb("d4d4d4")),
    ("custom", rgb("bb9af7")),
  ))
  // Strings reserve a header for their language badge; raw inputs stay inline.
  assert.eq(query(<header>).map(it => it.value), ("string",))
  assert.eq(query(<code-size>).map(it => it.value), (8.8pt,) * 5)
}

// Rust macros use the function accent in the scoped syntax palette.
#{
  show: codly.theme("github-light")
  show text: it => context {
    if it.text in ("format!", "println!") {
      [#metadata((it.text, text.fill))<rust-macro>]
    }
    it
  }
  show raw.where(block: true): codly.new
  ```rs
  format!("Hello, {name}!");
  println!("{}", greeting("Typst"));
  ```
}
#context {
  assert.eq(query(<rust-macro>).map(it => it.value), (
    ("format!", rgb("8250df")),
    ("println!", rgb("8250df")),
  ))
}
