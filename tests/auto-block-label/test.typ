#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 320pt, height: auto, margin: 5pt)

// The figure label alone supplies line, highlight, and annotation targets.
@listing:1 @marked @note
#figure(caption: [A labelled highlight])[
  #codly.new(
    raw("answer = 42", block: true),
    highlights: ((line: 1, start: 0, end: 6, label: <marked>),),
    annotations: ((start: 1, content: [Answer], label: <note>),),
  )
]<listing>

// Resolve ancestry through wrappers and deferred source preparation.
#figure(caption: [Wrapped])[
  #block[#codly.new(context raw("wrapped", block: true), block-label: auto)]
]<wrapped>
#figure(caption: [Alias])[
  #codly.new(raw("answer = 42", block: true, lang: "alias"), aliases: (alias: "py"))
]<aliased>
#figure(caption: [Rainbow])[
  #codly.new("call()", rainbow: true)
]<rainbow>
#figure(caption: [Diff])[
  #codly.new(raw("-old\n+new", lang: "diff,py", block: true))
]<patch>
#[
  #show raw.where(block: true): codly.new
  #figure(raw("automatic", block: true), caption: [Automatic conversion])<automatic>
]
#[
  #show figure.where(kind: raw): it => block(it)
  #figure(codly.new("restyled"), caption: [Restyled figure])<restyled>
]

// The nearest figure wins. An unlabeled inner figure stops inheritance.
#figure(caption: [Outer])[
  #figure(caption: [Inner])[#codly.new("nested")]<inner>
  #figure(caption: [Unlabeled inner])[#codly.new("unlabeled")]
]<outer>

// Preserve explicit overrides and opt-outs, including scoped settings.
#figure(caption: [Explicit target])[Explicit]<target>
#figure(caption: [Override])[
  #codly.new("override", block-label: <target>)
]<override>
#figure(caption: [Disabled])[#codly.new("disabled", block-label: none)]<disabled>
#[
  #show: codly.set_(block-label: none)
  #figure(caption: [Scoped opt-out])[#codly.new("scoped") ]<scoped>
]

// Neither a preceding figure nor an arbitrary label becomes an ancestor.
#figure(caption: [No label])[#codly.new("unlabeled sibling")]
#codly.new("standalone")<standalone>

#context {
  for (target, owner) in (
    (<listing:1>, <listing>),
    (<marked>, <listing>),
    (<note>, <listing>),
    (<wrapped:1>, <wrapped>),
    (<aliased:1>, <aliased>),
    (<rainbow:1>, <rainbow>),
    (<patch:1>, <patch>),
    (<patch:2>, <patch>),
    (<automatic:1>, <automatic>),
    (<restyled:1>, <restyled>),
    (<inner:1>, <inner>),
    (<target:1>, <target>),
  ) {
    let matches = query(target)
    assert.eq(matches.len(), 1, message: repr(target))
    assert.eq(e.fields((matches.first().numbering)()).block, owner)
  }
  for target in (<outer:1>, <override:1>, <disabled:1>, <scoped:1>, <standalone:1>) {
    assert.eq(query(target).len(), 0, message: repr(target))
  }
}
