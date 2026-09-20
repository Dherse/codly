#import "../../codly.typ" as codly

#show: codly.set_(aliases: (custom-alias: "codly-alias-test"))
#if sys.inputs.at("case") == "alias-theme" {
  codly.new(raw("keyword", lang: "custom-alias", block: true, theme: "99-local-resources.tmTheme"))
} else {
  codly.new(raw(
    "keyword",
    lang: "custom-alias",
    block: true,
    syntaxes: "99-local-resources.sublime-syntax",
  ))
}
