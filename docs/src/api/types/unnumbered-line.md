# `codly.unnumbered-line`

Selects a source line to show without its line number, optionally putting content in the number cell.

## Signature

```typst code
codly.unnumbered-line(line, fill: [])
```

Both arguments are positional: `line` is required and `fill` is optional.

## Parameters

| Parameter | Type | Default / required | Meaning |
| --- | --- | --- | --- |
| `line` | `int` | Required | One-indexed source line to display without a line number. |
| `fill` | `content` | `[]` | Content to display in the number cell instead. |

## Behavior

> [!NOTE] Source coordinates
> `line` is a one-indexed source line, even when a range or offset changes its
> displayed position or number.

> [!TIP] Later line numbers stay contiguous.
> An unnumbered line does not advance the displayed sequence. You can refer to
> consecutive unnumbered lines with `@block:l2p1`, `@block:l2p2`, and so on.

Pass entries to [`codly.new`](../components/new.md)'s `unnumbered` field. The constructor takes positional arguments; implicit casts accept an integer, a one- or two-element array, or a dictionary with `line` and optional `fill` fields. Array values are positional, and other array lengths do not cast. The coordinates always refer to source lines, even when ranges or offsets change which lines appear or their displayed numbers.

An unnumbered line does not advance the displayed number sequence, so later numbered lines remain contiguous. Consecutive unnumbered lines can be referenced with labels such as `@block:l2p1` and `@block:l2p2`, where the `l` number is the preceding displayed number and `p` counts the unnumbered lines after it.

## Example: Basic Usage

````typst preview
#import "@preview/codly:2.0.0" as codly

#figure(caption: [Unnumbered source lines])[
  #codly.new(
    ```
    first
    label:
    second
    end
    last
    ```,
    unnumbered: (
      codly.unnumbered-line(2, [↳]),
      codly.unnumbered-line(4),
    ),
  )
]<block>

The unnumbered lines are @block:l1p1 and @block:l2p1.
````
