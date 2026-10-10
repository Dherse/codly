#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 500pt, height: auto, margin: 8pt)

// A real two-file patch combines aliases, caller-relative custom resources,
// mapped old/new sublanguages, and independent rainbow stacks. Compare each
// visible code row with an ordinary marker-free render of the correct side.
#let palette = (rgb("e00000"), rgb("0000e0"), rgb("00a000"), rgb("a000a0"))
#set raw(
  theme: "../aliases/99-local-resources.tmTheme",
  syntaxes: "../aliases/99-local-resources.sublime-syntax",
)
#show: codly.set_(aliases: (custom-python: "py"), rainbow: (palette: palette))
#show: codly.line-show_(it => {
  let row = e.fields(it).body
  [#metadata((row.text, row.body))<interaction-line>#it]
})
#show text.where(text: "keyword"): it => context [#metadata(text.fill)<interaction-keyword>#it]
#show text: it => context {
  if text.fill in palette { [#metadata((it.text, text.fill))<interaction-bracket>#it] } else { it }
}

#let old = "f(\nkeyword([1])\n)"
#let new = "f(\nkeyword({2: 3})\n)"
#for source in (old, new) {
  codly.new(raw(source, lang: "custom-python", block: true), sublangs: (
    (start: 2, end: 2, lang: "codly-alias-test"),
  ))
}
#for source in ("keyword(9)", "keyword([8])") {
  codly.new(raw(source, lang: "custom-python", block: true), sublangs: (
    (start: 1, end: 1, lang: "codly-alias-test"),
  ))
}

#let patch = (
  "diff --git a/first.py b/first.py\n--- a/first.py\n+++ b/first.py\n"
    + "@@ -10,3 +20,3 @@ example\n f(\n-keyword([1])\n+keyword({2: 3})\n )\n"
    + "diff --git a/second.py b/second.py\n--- a/second.py\n+++ b/second.py\n"
    + "@@ -1 +1 @@\n-keyword(9)\n+keyword([8])"
)
#codly.new(raw(patch, lang: "diff,custom-python", block: true), sublangs: (
  (start: 6, end: 7, lang: "codly-alias-test"),
  (start: 13, end: 14, lang: "codly-alias-test"),
))

#context {
  let rows = query(<interaction-line>).map(it => it.value)
  let code = rows.filter(it => (
    it.first() in ("f(", ")", "keyword([1])", "keyword({2: 3})", "keyword(9)", "keyword([8])")
  ))
  assert.eq(code.len(), 14)
  assert.eq(code.slice(8), (code.at(3), code.at(1), code.at(4), code.at(5), code.at(6), code.at(7)))
  let passes = query(<__codly-diff-pass>).map(it => it.value)
  assert.eq(passes.len(), 4)
  assert.eq(passes.map(it => it.lines.map(line => line.text).join("\n")), (
    old,
    new,
    "keyword(9)",
    "keyword([8])",
  ))
  let keywords = query(<interaction-keyword>).map(it => it.value)
  assert.eq(keywords.len(), 8)
  assert.eq(keywords, (rgb("ff0000"),) * 8)
  let brackets = query(<interaction-bracket>).map(it => it.value)
  assert(brackets.len() > 0)
  assert(brackets.any(it => it.last() == palette.at(1)))
}
