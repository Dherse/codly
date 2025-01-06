// Compile with `typst compile tests/numbers-out-margin/test.typ --root . tests/numbers-out-margin/out/test.pdf` in root directory

#import "../../codly.typ": *

#set page("a4")

#show: codly-init


```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

= Numbers outside margin options

// Alignment is not good, neither total width
#codly(number-outside-margin: true)
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

#codly(number-outside-margin: false)
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

== Zebra fill effect
#codly(zebra-fill: none, number-outside-margin: false)
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

#codly(zebra-fill: none, number-outside-margin: true)
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

== Disabling number format but number outside margin enabled
#codly(number-format: none, number-outside-margin: true)
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```
== With number format but with number outside margin disabled as well
#codly(number-format: none, number-outside-margin: false)
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

= Annotations side effects

```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

#codly(annotations: ((start: 1, content: "Begin with that!"), ))
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

#codly(lang-format: auto)
#codly(annotations: ((start: 1, end: 3, content: "Begin with that!"), ))
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

= With highlight
#codly(highlights: ((line: 1, tag: "Hello, world!"), ))
#codly(inset: 0.5pt)
```typst
Hello, world!
```

#no-codly[
  ```typst
  Hello, world!
  ```
]

#codly(inset: 10pt)
```typst
Hello, world!
```

#codly(inset: 0.5pt)
```typst
Hello, world!
```

#codly-reset()
#codly(languages: (py: (name: "Python", icon: "Sss ", color: rgb("#4584b6")), ))
```py
# Example code that calculates the sum of the first 10 natural numbers squares
```