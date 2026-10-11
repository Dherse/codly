# API reference

- [Components](components/index.md) render code blocks and their parts.
- [Types](types/index.md) describe configuration values and their accepted shorthand forms.
- [Themes and helpers](helpers/index.md) apply reusable styles and inspect block metadata.
- [⚙️ Queries and show rules](queries-and-show-rules.md) explains how to inspect and customize elements.
- [⚙️ Internals](internals.md) follows a code block from source to layout and references.

## Imports

Import the Codly package as a namespace:

```typst
#import "@preview/codly:2.0.0" as codly
```

## Components and styling

> [!TIP] Style components with show rules.
> Use `#show: codly.number-set_(...)` to set defaults in scope.
> The `*-show_` helpers accept replacement content or a callback receiving
> the component, rather than a dictionary of field overrides.

Codly uses Elembic custom elements and types; the exported `codly.e` gives you the same Elembic version without a separate import. [`codly.new`](components/new.md) creates a code block, and component helpers such as [`codly.number-set_`](components/number.md#signature) apply scoped defaults with `#show:` rather than native `#set` syntax. See the [Elembic documentation](https://pgbiel.github.io/elembic/) for details.

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.number-set_(numbering: "1.")
#show raw.where(block: true): codly.new
```py
print(42)
print(43)
```
````

Each component page documents its constructor and its `*-set_` and `*-show_` helpers. Configuration types do not render directly — Codly instantiates them internally — and most accept dictionaries or arrays in place of an explicit constructor call; each type page lists its accepted forms.

## Coordinates and defaults

> [!NOTE] Source coordinates
> Source-line ranges and character highlight bounds are one-indexed and
> inclusive. Highlight `line` values use displayed line numbers, which
> can change with offsets and skipped lines.

Callout pointers and explicit skip positions have their own conventions, documented on their type pages. Check a field's definition before using displayed numbers as configuration coordinates.

`auto` and `none` have field-specific meanings. A default value does not always describe the final appearance: themes, scoped styling rules, and surrounding Typst text or raw settings can affect rendering.

`paint` means a color, gradient, or tiling; `array<T>` an array of `T` values.

> [!WARNING] Signatures describe types.
> Signature blocks show the accepted argument types; they are not runnable
> Typst examples. Use the preview examples as a starting point for your code.
