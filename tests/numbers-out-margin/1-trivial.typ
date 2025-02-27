// Compile with `typst compile tests/numbers-out-margin/test.typ --root . tests/numbers-out-margin/out/test.pdf` in root directory

#import "../../codly.typ": *

#set page("a4")

#show: codly-init

= First test

#codly(number-outside-margin: true)

```java
System.out.println("Hello, world!");
```

= Second test
```java
System.out.println("Hello, world!");
System.out.println("Hello, world!");
System.out.println("Hello, world!");
```

= Third test
```scala
def factorial(n: Int): Int = 

  @tailrec
  def loop(current: Int, accum: Int): Int = 
  
    if n == 0 then accum
    else loop(current - 1, n * accum)
  
  loop(n, 1) // Call to the closure using the base case
  
end factorial
```