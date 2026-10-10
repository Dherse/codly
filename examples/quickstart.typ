#import "../codly.typ" as codly
#import "_common.typ": frame
#show: frame
#show: codly.theme("github-light")
#show: codly.lang-set_(languages: (rs: (name: [Rust], color: rgb("b7502a"))))
#show: codly.set_(file: "greeting.rs")
#show raw.where(block: true): codly.new

```rs
pub fn greeting(name: &str) -> String {
    format!("Hello, {name}!")
}

fn main() {
    println!("{}", greeting("Typst"));
}
```

Inline code such as `greeting("Typst")` remains ordinary raw text.
