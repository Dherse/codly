#import "../../codly.typ" as codly

= First test

#{
  show: codly.e.set_(codly.number, placement: "outside", fill: none)
  codly.new[```java
  System.out.println("Hello, world!");
  ```]
}

= Second test
#{
  show: codly.e.set_(codly.number, placement: "outside", fill: none)
  codly.new[```java
  System.out.println("Hello, world!");
  System.out.println("Hello, world!");
  System.out.println("Hello, world!");
  ```]
}

= Third test
#{
  show: codly.e.set_(codly.number, placement: "outside", fill: none)
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
