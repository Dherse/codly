// Compile with `typst compile tests/numbers-out-margin/test.typ --root . tests/numbers-out-margin/out/test.pdf` in root directory

#import "../../codly.typ": *

#set page("a4")

#show: codly-init

= Standard simple
#codly(number-format: none)
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

#codly(number-format: numbering.with("1"))
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

#codly(number-format: numbering.with("1"), number-placement: "outside")
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

== Without zebra fill
#codly(zebra-fill: none, number-placement: "inside")
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

#codly(zebra-fill: none, number-placement: "outside")
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

#codly(zebra-fill: luma(240))

== Disabling number format but number outside margin enabled
#codly(number-format: none, number-placement: "outside")
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```
== With number format but with number outside margin disabled as well
#codly(number-format: numbering.with("1"), number-placement: "inside")
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

= Annotations side effects
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

#codly(lang-format: auto)
#codly(number-placement: "outside", annotations: ((start: 1, content: "Begin with that!"), ))
```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```

= With highlight

#codly(
  highlights: (
    (line: 1, start: 14, end: 18, fill: blue),
    (line: 3, start: 5, end:10, fill: green),
    (line: 3, start: 24, end:38, fill: blue),
  ),
)

```java
public class MyApp {
  public static void main(String[] args) {
    System.out.println("Hello, world!");
  }
}
```

#codly(number-placement: "inside")

#codly(
  highlights: (
    (line: 1, start: 14, end: 18, fill: blue),
    (line: 3, start: 5, end:10, fill: green),
    (line: 3, start: 24, end:38, fill: blue),
  ),
)

```java
public class MyApp {
  public static void main(String[] args) {
    System.out.println("Hello, world!");
  }
}
```