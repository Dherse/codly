// Compile with `typst compile tests/numbers-out-margin/test.typ --root . tests/numbers-out-margin/out/test.pdf` in root directory

#import "../../codly.typ": *

#set page("a4")

#show: codly-init

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

#codly(number-placement: "outside")

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