#import "../../codly.typ": codly-reset

#include "22-highlight-align.typ"
#pagebreak()
#codly-reset()

#include "32-spacing.typ"
#pagebreak()
#codly-reset()

#include "36-highlight-bug.typ"
#pagebreak()
#codly-reset()

#include "39-offset-by-name.typ"
#pagebreak()
#codly-reset()

#include "40-header-no-number.typ"  
#pagebreak()
#codly-reset()

/*
Waiting for typst-test update:
#assert-panic(() => {
  include "47-crash-label.typ"
  pagebreak()
}, message: "inequality assertion failed: codly: for labels on highlights to work, you must have the code block 
contained within a figure and that figure must have a label.")*/
#codly-reset()

#include "50-skips-no-reset.typ"
#pagebreak()
#codly-reset()

#include "52-skip-line-disabled.typ"
#pagebreak()
#codly-reset()

#include "56-contextual-funcs.typ"
#pagebreak()
#codly-reset()

#include "63-continue-highlights.typ"
#pagebreak()
#codly-reset()

#include "71-no-highlights-in-local.typ"
#codly-reset()