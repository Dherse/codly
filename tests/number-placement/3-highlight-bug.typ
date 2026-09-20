#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

= With highlight

#codly.new(
  highlights: (
    (line: 1, start: 14, end: 18, fill: blue),
    (line: 3, start: 5, end: 10, fill: green),
    (line: 3, start: 24, end: 38, fill: blue),
  ),
)[```java
public class MyApp {
  public static void main(String[] args) {
    System.out.println("Hello, world!");
  }
}
```]

#{
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  codly.new(highlights: (
    (line: 1, start: 14, end: 18, fill: blue),
    (line: 3, start: 5, end: 10, fill: green),
    (line: 3, start: 24, end: 38, fill: blue),
  ))[```java
  public class MyApp {
    public static void main(String[] args) {
      System.out.println("Hello, world!");
    }
  }
  ```]
}
