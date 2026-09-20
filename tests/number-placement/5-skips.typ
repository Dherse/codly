#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

= Code skips

#codly.new(skips: ((4, 32),))[```py
def fib(n):
    if n <= 1:
        return n
    return fib(n - 1) + fib(n - 2)

fib(25)
```]

#{
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  codly.new(skips: ((4, 32),))[```py
  def fib(n):
      if n <= 1:
          return n
      return fib(n - 1) + fib(n - 2)

  fib(25)
  ```]
}

#{
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  codly.new(
    skips: ((4, 120),),
    skip-number: align(center, emoji.face.shock),
  )[```py
  def fib(n):
    if n <= 1:
      return n
    return fib(n - 1) + fib(n - 2)

  fib(25)
  ```]
}

#codly.new(
  skips: ((4, 120),),
  skip-number: align(
    center,
    emoji.face.shock,
  ),
)[```py
def fib(n):
  if n <= 1:
    return n
  return fib(n - 1) + fib(n - 2)

fib(25)
```]
