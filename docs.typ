= Codly Documentation

#show link: underline

Documentation generated using #link("https://typst.app/universe/package/tidy", text(fill: blue)[tidy]) version 0.2.0.

#import "@preview/tidy:0.2.0"
#let docs = tidy.parse-module(read("codly.typ"))
#tidy.show-module(docs, style: tidy.styles.default)

