#import "../../codly.typ" as codly

#set page(width: 160pt, height: auto, margin: 5pt)

// Check immediate argument diagnostics; run.py covers deferred layout failures.
#let rejects(expected, args) = context {
  let message = catch(() => measure(codly.new(raw("one\ntwo\nthree", block: true), ..args)))
  assert(message != none, message: "accepted invalid arguments: " + repr(args))
  assert(message.contains(expected), message: "expected " + expected + ", got " + message)
}

#for (expected, args) in (
  ("greater than 0", (highlights: ((line: 0),))),
  ("at least 0", (highlights: ((line: 1, start: -1),))),
  ("at least 0", (highlights: ((line: 1, end: -1),))),
  ("greater than 0", (annotations: ((start: 0),))),
  ("greater than 0", (annotations: ((start: 1, end: 0),))),
  ("at least `start`", (annotations: ((start: 3, end: 2),))),
  ("greater than 0", (callouts: ((line: 0, body: []),))),
) {
  rejects(expected, args)
}

#context {
  assert(catch(() => codly.info(<missing-info>)).contains("unique code block label"))
}
