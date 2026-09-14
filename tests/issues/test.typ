#import "../../codly.typ" as codly

#include "22-highlight-align.typ"
#pagebreak()

#include "32-spacing.typ"
#pagebreak()

#include "36-highlight-bug.typ"
#pagebreak()

#include "39-offset-by-name.typ"
#pagebreak()

#include "40-header-no-number.typ"  
#pagebreak()

/*
Waiting for typst-test update:
#assert-panic(() => {
  include "47-crash-label.typ"
  pagebreak()
}, message: "inequality assertion failed: codly: for labels on highlights to work, you must have the code block 
contained within a figure and that figure must have a label.")*/

#include "50-skips-no-reset.typ"
#pagebreak()

#include "52-skip-line-disabled.typ"
#pagebreak()

#include "56-contextual-funcs.typ"
#pagebreak()

#include "63-continue-highlights.typ"
#pagebreak()

#include "71-no-highlights-in-local.typ"
#pagebreak()

#include "81-highlight-inset-with-tags.typ"
#pagebreak()

#include "85-annotation-labels.typ"
#pagebreak()

#include "89-nested-highlights.typ"