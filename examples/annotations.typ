#import "../codly.typ" as codly
#import "_common.typ": frame
#show: frame
#show: codly.theme("github-light")
#show: codly.callout-set_(source-indent: true)
#show: codly.ref-set_(sep: [ · line ])

#figure(caption: [A bounded retry loop])[
  #codly.new(
    raw(
      "def retry(operation, attempts=3):\n    for attempt in range(attempts):\n        try:\n            return operation()\n        except TimeoutError:\n            if attempt + 1 == attempts:\n                raise",
      lang: "py",
      block: true,
    ),
    file: "retry.py",
    block-label: <retry>,
    padding: (y: 5pt),
    highlights: (
      (line: 4, start: 20, end: 30, tag: "success", label: <success>),
      (line: 7, start: 17, end: 21, tag: "failure"),
    ),
    annotations: ((start: 2, end: 7, content: [Retry loop], numbering: none),),
    callouts: (
      (line: 4, body: [Return immediately when the operation succeeds.]),
      (line: 6, pointer: 16, placement: "above", body: [Re-raise after the final attempt.]),
    ),
  )
]<retry>

The successful result is returned at @success; the error path starts at @retry:5.
