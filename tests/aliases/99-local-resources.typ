#import "../../codly.typ" as codly

#set page(width: 220pt, height: auto, margin: 5pt)
#show text.where(text: "keyword"): it => context [#metadata(text.fill)<alias-token-color>#it]

// Both paths are relative to this test, not Codly's source directory.
// Direct relative raw arguments must use path(...) or read(...); plain strings
// are safe when inherited through this set rule.
#set raw(
  theme: "99-local-resources.tmTheme",
  syntaxes: "99-local-resources.sublime-syntax",
)
#show: codly.set_(aliases: (custom-alias: "codly-alias-test"))
#codly.new(raw("keyword", lang: "custom-alias", block: true))

// A resolved path retains its caller origin when copied through the alias.
#codly.new(raw(
  "keyword",
  lang: "custom-alias",
  block: true,
  theme: path("99-local-resources.tmTheme"),
  syntaxes: path("99-local-resources.sublime-syntax"),
))

#codly.new(raw(
  "keyword",
  lang: "custom-alias",
  block: true,
  theme: read("99-local-resources.tmTheme", encoding: none),
  syntaxes: read("99-local-resources.sublime-syntax", encoding: none),
))

#context {
  assert.eq(query(<alias-token-color>).map(it => it.value), (rgb("#ff0000"),) * 3)
}
