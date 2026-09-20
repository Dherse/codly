#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

= Standard simple
#codly.new(number-enabled: false)[```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```]

#codly.new[```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```]

#{
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  codly.new[```java
  public static void main(String args[]) {
      System.out.println("Hello, world!");
  }
  ```]
}

== Without zebra fill
#{
  show: codly.line-set_(zebra-fill: none)
  show: e.set_(codly.codly-number, placement: "inside")
  codly.new[```java
  public static void main(String args[]) {
      System.out.println("Hello, world!");
  }
  ```]
}

#{
  show: codly.line-set_(zebra-fill: none)
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  codly.new[```java
  public static void main(String args[]) {
      System.out.println("Hello, world!");
  }
  ```]
}

== Disabling number format but number outside margin enabled
#{
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  codly.new(number-enabled: false)[```java
  public static void main(String args[]) {
      System.out.println("Hello, world!");
  }
  ```]
}
== With number format but with number outside margin disabled as well
#{
  show: e.set_(codly.codly-number, placement: "inside")
  codly.new[```java
  public static void main(String args[]) {
      System.out.println("Hello, world!");
  }
  ```]
}

= Annotations side effects
#codly.new(annotations: ((start: 1, content: "Begin with that!"),))[```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```]

#codly.new(annotations: ((start: 1, end: 3, content: "Begin with that!"),))[```java
public static void main(String args[]) {
    System.out.println("Hello, world!");
}
```]

#{
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  codly.new(annotations: ((start: 1, content: "Begin with that!"),))[```java
  public static void main(String args[]) {
      System.out.println("Hello, world!");
  }
  ```]
}

= With highlight

#{
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  codly.new(
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
}

#{
  show: e.set_(codly.codly-number, placement: "inside")
  codly.new(
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
}
