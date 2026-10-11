# `codly.diff`

Configures automatic parsing, syntax highlighting, gutters, and row fills for raw blocks whose language is `diff-<language>` or `diff,<language>`.

## Signature

```typst code
codly.diff(
  enabled: bool = true,
  added-fill: auto | paint | function = rgb("dafbe1"),
  removed-fill: auto | paint | function = rgb("ffebe9"),
  meta-fill: auto | paint | function = rgb("ddf4ff"),
  context-fill: auto | paint | function = auto,
  numbers: bool = true,
  markers: bool = true,
  added-marker: str | content = "+",
  removed-marker: str | content = "−",
  old-offset: int = 0,
  new-offset: int = 0,
)
```

The fields can also be supplied as a dictionary. A boolean casts to `enabled`.

## Fields

{{#arg-table types.diff}}

## Behavior

> [!TIP] Use the patch language prefix
> Set the raw block language to `diff-<language>` or `diff,<language>`, such as `diff-py` or `diff,py`, to enable patch parsing and highlight the changed code as Python.

> [!NOTE] Patch line coordinates
> References and line-based settings use displayed patch-row numbers. Highlight and callout character positions count code after the diff marker is removed.

> [!WARNING] Combined merge diffs are unsupported
> Codly parses unified patches, including multiple files and hunks, but not combined merge diff format.

With the block-level `diff` setting at `auto` (the default), Codly detects both prefixes and strips them for syntax highlighting. Old and new source views are rendered separately, so removed code does not affect new-side syntax state. Unified patches may contain multiple files and hunks, each highlighted independently. A non-patch snippet may use ` `, `+`, and `-` prefixes for context, added, and removed rows.

For fenced blocks, `diff-py` works in Typst 0.15; use `raw(..., lang: "diff,py")` on versions without comma support in language tags.

Each fill accepts a paint, `none`, or `auto`; `auto` uses the ordinary row fill. A callback receives the row with a `diff` record containing `kind`, `old`, and `new` line coordinates, as well as the row's usual fields. Explicit highlights take precedence over diff fills. Setting `diff: false` or `diff: none` disables processing; setting it to `true` enables the default configuration. Custom `gutters` replace the automatic old/new/marker columns.

## Example: Basic Usage

```yaml widgets
- type: switch
  name: diff-enabled
  label: Process the diff
  default: true
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```diff-py
   shared
  -old = 1
  +new = 2
   tail
  ```,
  diff: if diff-enabled { auto } else { false },
)
````
