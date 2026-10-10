#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 480pt, height: auto, margin: 3pt)
#show: codly.show_(it => {
  let fields = e.fields(it)
  if fields.__diff-pass == none and fields.__diff == none {
    [#metadata(fields.radius)<converted>#it]
  } else { it }
})
#[
  #show raw.where(block: true): codly.new

  ```py
  print("automatic")
  ```

  Inline `print("inline")` stays raw.

  // Explicit blocks must not be converted a second time.
  #codly.new(raw("explicit", block: true))

  #{
    show: codly.set_(radius: 9pt)
    raw("scoped", block: true)
  }

  #raw("-return 1\n+return 2", lang: "diff,py", block: true)
]

// Blocks outside the scope stay native; inline raw was never selected.
#raw("opted out", block: true)

#context {
  let converted = query(<converted>).map(it => it.value)
  assert.eq(converted.len(), 4)
  assert.eq(converted.at(2), 9pt)
  assert.eq(converted.first(), converted.last())
}
