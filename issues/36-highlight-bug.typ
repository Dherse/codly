#import "../codly.typ": *

#set page(height: auto, width: 10cm, margin: 1em)
#show: codly-init.with()

#codly(
  highlights: (
    (line: 0, start: 14, end: 18, fill: blue),
    (line: 2, start: 5, end:10, fill: green),
    (line: 2, start: 24, end:38, fill: blue),
  ),
)

```java
public class MyApp {
  public static void main(String[] args) {
    System.out.println("Hello, world!");
  }
}
```