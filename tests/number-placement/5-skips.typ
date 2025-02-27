// Compile with `typst compile tests/numbers-out-margin/test.typ --root . tests/numbers-out-margin/out/test.pdf` in root directory

#import "../../codly.typ": *

#set page("a4")

#show: codly-init

= Code skips

#codly(skips: ((4, 32), ))
```py
def fib(n):
    if n <= 1:
        return n
    return fib(n - 1) + fib(n - 2)

fib(25)
```

#codly(number-placement: "outside")
#codly(skips: ((4, 32), ))
```py
def fib(n):
    if n <= 1:
        return n
    return fib(n - 1) + fib(n - 2)

fib(25)
```

#codly(
skips: ((4, 120), ),
skip-number: align(center,
emoji.face.shock)
)
```py
def fib(n):
  if n <= 1:
    return n
  return fib(n - 1) + fib(n - 2)

fib(25)
```

#codly(
  skips: ((4, 120), ),
  skip-number: align(
      center,
      emoji.face.shock),
  number-placement: "inside")
```py
def fib(n):
  if n <= 1:
    return n
  return fib(n - 1) + fib(n - 2)

fib(25)
```