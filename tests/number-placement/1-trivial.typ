#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

= First test

#{
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  codly.new[```java
  System.out.println("Hello, world!");
  ```]
}

= Second test
#{
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  codly.new[```java
  System.out.println("Hello, world!");
  System.out.println("Hello, world!");
  System.out.println("Hello, world!");
  ```]
}

= Third test
#{
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  codly.new[```scala
  def factorial(n: Int): Int =

    @tailrec
    def loop(current: Int, accum: Int): Int =

      if n == 0 then accum
      else loop(current - 1, n * accum)

    loop(n, 1) // Call to the closure using the base case

  end factorial
  ```]
}
