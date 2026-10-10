#import "../../codly.typ" as codly

#set page(width: 380pt, height: auto, margin: 8pt)
#set text(size: 9pt)

#let source = "-/* old multiline comment\n+int fresh = 1;\n  shared\n-old comment ends */\n+int later = 2;\n int stable = 3;"
#codly.new(
  raw(source, lang: "diff,c", block: true),
  header: [Two independent syntax views],
  footer: [Context uses the new view],
)
#codly.new(raw(
  "diff --git a/main.py b/main.py\nindex 1111111..2222222 100644\n--- a/main.py\n+++ b/main.py\n@@ -10,3 +20,3 @@ example\n def main():\n-    return 'old'\n+    return 'new'\n main()\n@@ -30,0 +40,1 @@\n+print('done')\n\\ No newline at end of file",
  lang: "diff,py",
  block: true,
))
#{
  show: codly.theme("dark")
  codly.new(raw(source, lang: "diff,c", block: true), file: "main.c", header: [Dark diff])
}
#{
  show: codly.theme("clean")
  codly.new(raw("-before\n+after\n context", lang: "diff,py", block: true), number-enabled: false)
}

#pagebreak()
#{
  show: codly.number-set_(placement: "outside")
  show: codly.line-set_(stroke: blue + 0.8pt)
  codly.new(
    raw(
      " def main():\n-    return 'a long old value with many words to wrap naturally across the line'\n+    return 'a long new value with many words to wrap naturally across the line'\n main()",
      lang: "diff,py",
      block: true,
    ),
    header: [Outside gutters, wraps, guides, annotations, and callouts],
    footer: [Footer],
    indent-guides: (width: 4),
    wrap-marker: [↪],
    radius: 8pt,
    annotations: ((start: 2, end: 3, content: [change]),),
    callouts: ((line: 3, pointer: 11, body: [New value]),),
  )
}
#codly.new(raw("-old\n+new\n context", lang: "diff,py", block: true), width: auto, diff: (
  added-fill: gradient.linear(aqua.lighten(75%), green.lighten(75%)),
  removed-fill: none,
  context-fill: row => if row.diff.old != none { yellow.lighten(75%) },
))
#codly.new(
  raw("-old\n+new", lang: "diff,py", block: true),
  gutters: (auto, (values: ("old", "new"), fill: none)),
  header: [Custom columns],
)
#codly.new(raw("-old\n+new", lang: "diff,py", block: true), diff: (numbers: false, markers: false))
#codly.new(raw("-not processed\n+still literal", lang: "diff,py", block: true), diff: false)
