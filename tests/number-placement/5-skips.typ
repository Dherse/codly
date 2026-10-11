#import "../../codly.typ" as codly

= Code skips

#codly.new(skips: ((4, 32),))[```py
def fib(n):
    if n <= 1:
        return n
    return fib(n - 1) + fib(n - 2)

fib(25)
```]

#{
  show: codly.e.set_(codly.number, placement: "outside", fill: none)
  codly.new(skips: ((4, 32),))[```py
  def fib(n):
      if n <= 1:
          return n
      return fib(n - 1) + fib(n - 2)

  fib(25)
  ```]
}

#{
  show: codly.e.set_(codly.number, placement: "outside", fill: none)
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
