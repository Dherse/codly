# `codly.ref`

> [!WARNING] References need a labelled figure.
> Line, highlight, and annotation references require the code block to sit inside a labelled figure; Codly discovers the figure label automatically.

Sets shared formatting for references to code lines, highlights, and annotations.

## Signature

```typst code
codly.ref(body, by: "line", sep: "-", numbering: numbering.with("1"))
codly.ref-set_(..fields)
```

[`codly.ref`](#signature) is an element definition; [`codly.ref-set_(...)`](#signature) is a set-rule wrapper for its fields, not a separate element. There is no `ref-show_`: references render through native syntax and the show rules of the generated reference elements.

## Fields

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `body` | `content` \| `none` | required | Content of the reference element. |
| `by` | `"line"` \| `"item"` \| `none` | `"line"` | Choose a displayed line number or an item label/content for highlight and annotation references. |
| `sep` | `str` \| `content` \| `none` | `"-"` | Content between the native reference to the code block and the line number or item. |
| `numbering` | `function` \| `none` | `numbering.with("1")` | Formats line numbers when `by` is `"line"`; `none` leaves the native block reference without a line suffix. |

## Behavior

> [!TIP] Choose what the reference shows.
> The shared `by: "line"` setting shows the displayed line number. `by: "item"` shows the highlight tag or annotation content instead.

> [!WARNING] Item references to highlights need a tag.
> When `by: "item"`, each referenced highlight must define a `tag`; Codly reports an error if the tag is missing. Annotation item references use the annotation's `content`.

The fields in [`codly.ref`](#signature) are shared defaults for [`codly.line-ref`](line-ref.md), [`codly.highlight-ref`](highlight-ref.md), and [`codly.annotation-ref`](annotation-ref.md). A field set directly on one of those generated reference elements takes precedence over the shared setting. `by: "item"` uses the highlight's tag or the annotation's content; line references always refer to a displayed line. Numbering callbacks receive the displayed line number. These references resolve to the containing code figure or block, so ordinary Typst reference formatting still applies to that target.

See [`codly.line-ref`](line-ref.md), [`codly.highlight-ref`](highlight-ref.md), and [`codly.annotation-ref`](annotation-ref.md) for the generated reference fields.

## Example

This figure labels a code block and an annotation. The reference to the annotation uses its content as the item suffix:

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.ref-set_(by: "item", sep: " — ")

#figure(caption: [A code example])[
  #codly.new(
    ```
    first line
    second line
    ```,
    annotations: ((start: 2, label: <note>, content: [the note]),),
  )
]<example>

The annotation reference is @note and the line is @example:2.
````
