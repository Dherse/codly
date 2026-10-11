# API reference

The current API reference for the Codly package.

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

Codly uses Elembic custom elements and types. Access Elembic through `codly.e` to use the same version as Codly, without importing it separately. [`codly.new`](components/new.md) creates a code block. Component helpers such as [`codly.number-set_`](components/number.md#signature) apply defaults within the surrounding Typst scope. They are used with `#show:`, rather than native `#set` syntax. Refer to the [elembic documentation](https://pgbiel.github.io/elembic/) for more information.

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.number-set_(numbering: "1.")
#show raw.where(block: true): codly.new
```py
print(42)
print(43)
```
````

Each component page documents its constructor and available `*-set_` and `*-show_` helpers. Many configuration types do not render content directly, instead being meant to be called internally by Codly. Most values can be built from dictionaries or arrays instead of needing manual type invocation. Whether the elements/types can be shown and their constructors are detailed on their respective pages.

## Coordinates and defaults

> [!NOTE] Source coordinates
> Source-line ranges are one-indexed and inclusive. Character highlights
> use zero-indexed offsets with an exclusive `end`. Displayed line numbers
> can change with offsets and skipped lines.

Source-line ranges are one-based and include both endpoints. Character highlights use zero-based bounds with an exclusive end; callout pointers and explicit skip positions have their own conventions documented on their type pages. Displayed line numbers can differ from source positions after applying an offset. Check the field's definition before using displayed numbers as configuration coordinates.

`auto` and `none` have field-specific meanings. A default value does not always describe the final appearance: themes, scoped styling rules, and surrounding Typst text or raw settings can affect rendering.

`paint` means a color, gradient, or tiling. `array<T>` means an array of values of type `T`. The type notation in signature blocks describes accepted values; it is not runnable Typst syntax. The preview examples are runnable and editable.

> [!WARNING] Signatures describe types.
> Signature blocks show the accepted argument types; they are not runnable
> Typst examples. Use the preview examples as a starting point for your code.
