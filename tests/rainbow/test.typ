#import "../../codly.typ" as codly
#import "../../src/rainbow.typ" as r
#import "@preview/elembic:1.1.1" as e

#set page(width: 280pt, height: auto, margin: 5pt)

// These expectations describe every eligible delimiter, including unmatched ones.
#let check(lang, source, expected, pairs: ("()", "[]", "{}"), syntaxes: ()) = {
  show raw: it => {
    let marks = r.scan(it.lines, pairs)
    let actual = ""
    for (line, positions) in marks {
      let source = it.lines.at(int(line) - 1).text
      for (at, depth) in positions {
        actual += (if depth == none { "?" } else { str(depth) }) + source.slice(at, at + 1)
      }
    }
    assert.eq(actual, expected, message: lang + ": " + source)
    []
  }
  raw(source, lang: lang, block: true, syntaxes: syntaxes, theme: r.theme(
    r.code-scopes,
    r.ignore-scopes,
  ))
}

#check(
  "rs",
  "fn f() { println!(\"{}\", \"}\"); let s = r###\"{\"###; let c = '}'; }",
  "0(0)0{1(1)0}",
)
#check("rs", "fn f() { /* } /* { */ ] */\n[1]\n}", "0(0)0{1[1]0}")
#check("js", "function f() { return `literal { ${g({x: \"}\"})} }`; }", "0(0)0{1{2(3{3}2)1}0}")
#check("js", "const r = /[{}()]/g; const x = a / b; f([]); // {", "0(1[1]0)")
#check("js", "`outer ${foo(`inner ${bar({a: \"}\"})}`)}`", "0{1(2{3(4{4}3)2}1)0}")
#check(
  "py",
  "def f():\n  s = f\"literal {{ {g({'x': '}'})} }}\"\n  # {}\n  return []",
  "0(0)0{1(2{2}1)0}0[0]",
)
#check("py", "s = ''' {\n ] } '''\nf(\"escaped \\\" {\")", "0(0)")
#check("c", "int f() { char *s = \"}\\\"{\"; /* { */ return (1); }", "0(0)0{1(1)0}")
#check("json", "{\"}\": [\"{\", {\"x\": 1}]}", "0{1[2{2}1]0}")
#check("cpp", "f(R\"tag({[]})tag\", '}'); // {", "0(0)")
#check("lua", "f([=[ { [ ] } ]=]) -- {", "0(0)")
#check("sql", "SELECT f('it''s }', 1); -- {", "0(0)")
#check("bash", "f() { echo '}' \"{\"; } # {", "0(0)0{0}")
#check("r", "f <- function(x) { list(a = c(1, 2), b = \"}\") } # (", "0(0)0{1(2(2)1)0}")
#check("r", "f(`{`, \"}\")", "0(0)")
#check("r", "x[[1]]; r\"({})\"", "0[1[1]0]")
#check("typc", "let f(x) = { \"}\"; (x,) } // {\n[hi #f(1)]", "0(0)0{1(1)0}0[1(1)0]")
#check("rs", "é\t😀({})", "0(1{1}0)")
#check("rs", "{\r\n[1]\r\n}", "0{1[1]0}")
#check("rs", "([)]", "?(1[?)1]")
#check("rs", "() {", "0(0)?{")
#check("rs", "f({[]})", "0{0}", pairs: ("{}",))
#check("rs", "f(<1); a > b;", "0(0)")
#check("codly-unknown", "f({}) // {", "")
#check("codly-rainbow-test", "word(%}%)", "0(0)", syntaxes: path("custom.sublime-syntax"))

#let colors = (rgb("#e00000"), rgb("#0000e0"), rgb("#00a000"))
#let settings = e.fields(codly.rainbow(
  palette: colors,
  pairs: ("{}",),
  code-scopes: "source.custom",
))
#assert.eq(settings.palette, colors)
#assert.eq(settings.pairs, ("{}",))
#assert.eq(settings.code-scopes, "source.custom")
#let record-line(it) = {
  let body = e.fields(it).body
  if body.func() != raw.line { return it }
  show text: t => context {
    if t.text == "word" { [#metadata(text.fill)<word-color>] }
    if text.fill in colors { [#metadata((t.text, text.fill))<rainbow-color>#t] } else { t }
  }
  [#metadata((body.number, body.text))<rainbow-line>#it]
}

// Exact rendered colors, with original text and native references preserved.
@colored:2 @mark
#context {
  let origin = here()
  show: codly.line-show_(record-line)
  [#figure(caption: [Rainbow])[
    #codly.new(
      raw("{\nf([1], \"}\")\n}", lang: "js", block: true),
      block-label: <colored>,
      rainbow: (palette: colors),
      range: (2, 2),
      highlights: ((line: 2, start: 2, end: 5, label: <mark>),),
    )
  ]<colored>]
  context {
    let seen = query(selector(<rainbow-color>).after(origin).before(here())).map(it => it.value)
    assert.eq(seen, (
      ("(", colors.at(1)),
      ("[", colors.at(2)),
      ("]", colors.at(2)),
      (")", colors.at(1)),
    ))
    assert.eq(query(<colored:2>).len(), 1)
    assert.eq(query(<mark>).len(), 1)
    assert.eq(codly.info(<colored>), (last-number: 2, lines: 3))
  }
}

// Sublanguages have independent stacks and restore the parent's nesting.
#context {
  let origin = here()
  show: codly.line-show_(record-line)
  codly.new(
    raw("{\nf({x: \"}\"})\ng([])\n}", lang: "rs", block: true),
    rainbow: (palette: colors),
    sublangs: ((start: 2, end: 2, lang: "js"),),
    offset: 10,
    annotations: ((start: 2, end: 3, content: [mixed]),),
  )
  context {
    let seen = query(selector(<rainbow-color>).after(origin).before(here())).map(it => it.value)
    assert.eq(seen, (
      ("{", colors.at(0)),
      ("(", colors.at(0)),
      ("{", colors.at(1)),
      ("}", colors.at(1)),
      (")", colors.at(0)),
      ("(", colors.at(1)),
      ("[", colors.at(2)),
      ("]", colors.at(2)),
      (")", colors.at(1)),
      ("}", colors.at(0)),
    ))
    let lines = query(selector(<rainbow-line>).after(origin).before(here())).map(it => it.value)
    assert.eq(lines.map(it => it.first()), (11, 12, 13, 14))
    assert.eq(lines.at(1).last(), "f({x: \"}\"})")
  }
}

// Palette cycling, pair selection and unmatched styling are independent.
#context {
  let origin = here()
  show: codly.line-show_(record-line)
  codly.new(raw("f({[]}) }", lang: "rs", block: true, theme: none), rainbow: (
    palette: colors,
    pairs: ("{}",),
    depth-offset: 4,
    unmatched: colors.at(2),
  ))
  context {
    let seen = query(selector(<rainbow-color>).after(origin).before(here())).map(it => it.value)
    assert.eq(seen, (("{", colors.at(1)), ("}", colors.at(1)), ("}", colors.at(2))))
  }
}

#context {
  let origin = here()
  set raw(syntaxes: "custom.sublime-syntax", theme: "../aliases/99-local-resources.tmTheme")
  show: codly.line-show_(record-line)
  codly.new(
    raw("word(%}%)\nword([1]) ~ }", lang: "custom-alias", block: true),
    aliases: (custom-alias: "codly-rainbow-test"),
    rainbow: (palette: colors, ignore-scopes: r.ignore-scopes + ", custom.ignored"),
    sublangs: ((start: 2, end: 2, lang: "codly-rainbow-test"),),
  )
  context {
    assert.eq(
      query(selector(<word-color>).after(origin).before(here())).map(it => it.value),
      (rgb("#ff0000"),) * 2,
    )
    let seen = query(selector(<rainbow-color>).after(origin).before(here())).map(it => it.value)
    assert.eq(seen, (
      ("(", colors.at(0)),
      (")", colors.at(0)),
      ("(", colors.at(0)),
      ("[", colors.at(1)),
      ("]", colors.at(1)),
      (")", colors.at(0)),
    ))
  }
}

// Speculative measurements must retain the normal wrapping and line heights.
#context {
  let body = raw(
    "\tfn é(x) { let y = [1, 2, 3]; f(x, y); }\n// comment {\n",
    lang: "rs",
    block: true,
  )
  assert.eq(measure(codly.new(body), width: 120pt), measure(
    codly.new(body, rainbow: true),
    width: 120pt,
  ))
  show raw: set text(font: "Libertinus Serif", size: 0.9em)
  show raw.where(block: true): set text(0.8em)
  assert.eq(measure(codly.new(body), width: 120pt), measure(
    codly.new(body, rainbow: true),
    width: 120pt,
  ))
}

#context {
  let origin = here()
  show: codly.line-show_(record-line)
  {
    show: codly.set_(rainbow: (palette: colors))
    codly.new(raw("fn f() {}", lang: "rs", block: true), rainbow: false)
    codly.new(raw("()", lang: "rs", block: true), rainbow: (pairs: ()))
  }
  codly.new(raw("let answer = 42;", lang: "rs", block: true), rainbow: true)
  context {
    assert.eq(query(selector(<__codly-rainbow>).after(origin).before(here())).len(), 0)
    assert.eq(query(selector(<rainbow-color>).after(origin).before(here())).len(), 0)
  }
}

#context {
  for (options, message) in (
    ((palette: ()), "palette must not be empty"),
    ((depth-offset: -1), "depth-offset must be nonnegative"),
  ) {
    let error = catch(() => measure(codly.new(
      raw("()", lang: "rs", block: true),
      rainbow: options,
    )))
    assert(error != none and error.contains(message))
  }
}
