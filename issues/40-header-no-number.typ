#import "../codly.typ": codly-init, codly

#show: codly-init

#codly(header: [ Hello, world! ], footer: [ Goodbye, world! ])
```py
def fib(n):
  if n <= 1:
      return n
  return fib(n - 1) + fib(n - 2)

print(fib(10))
```


#codly(number-format: none, header: [ Hello, world! ], footer: [ Goodbye, world! ])
```py
def fib(n):
  if n <= 1:
      return n
  return fib(n - 1) + fib(n - 2)

print(fib(10))
```
