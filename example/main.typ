#import "../codly.typ": *

#show: codly-init.with()

#let icon(codepoint) = {
  box(
    height: 0.8em,
    baseline: 0.05em,
    image(codepoint)
  )
  h(0.1em)
}

#codly(languages: (
  rust: (name: "Rust", icon: icon("brand-rust.svg"), color: rgb("#CE412B")),
  python: (name: "Python", icon: icon("brand-python.svg"), color: rgb("#3572A5")),
  typst: (name: "Typst", icon: none, color: rgb("#239dad"))
))

```rust
pub fn main() {
    println!("Hello, world!");
}
```

```python
def fibonaci(n):
    if n <= 1:
        return n
    else:
        return(fibonaci(n-1) + fibonaci(n-2))
```

We can also set a line number offset with `codly-offset(int)`:

#codly-offset(offset: 1)
```rust
    println!("Hello, world!");
```

And we can also disable line numbers:

#codly(enable-numbers: false)

```rust
pub fn main() {
    println!("Hello, world!");
}
```

We can also select only a range of lines to show. From this:

// probably enable numbers to show the range
#codly(enable-numbers: true)

// also show how we generate it
#raw(lang: "typst", block: true,
"#codly-range(start: 5, end: 5)

```python
def fibonaci(n):
    if n <= 1:
        return n
    else:
        return(fibonaci(n-1) + fibonaci(n-2))
```")

to this:

#codly-range(start: 5, end: 5)

```python
def fibonaci(n):
    if n <= 1:
        return n
    else:
        return(fibonaci(n-1) + fibonaci(n-2))
```

#codly(
  stroke-width: 1pt,
  stroke-color: red,
)

```rust
pub fn main() {
    println!("Hello, world!");
}
```


#codly(
  display-icon: false,
  stroke-color: luma(240),
  zebra-color: luma(240),
  enable-numbers: true,
)

```rust
pub fn main() {
    println!("Hello, world!");
}
```

```rust
pub fn function<R, S, T>() -> R where T: From<S>, S: Into<R>, R: Send + Sync + 'static {
    println!("Hello, world!");
}
```

#v(25%)

#codly(
  breakable: true
)

```rust
pub fn main() {
    println!("This is in another page!");
}
```

#codly(numbers-format: strong)

```rust
pub fn main() {
    println!("Strong line numbers go brrrrrrr.");
}
```

#codly(zebra-color: none, fill: black)
#show raw.where(block: true): set text(fill: white)

```rust
pub fn main() {
    println!("Dark style works too");
}
```

