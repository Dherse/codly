#import "../../codly.typ" as codly

#codly.new(header: [ Hello, world! ], footer: [ Goodbye, world! ], ```py
def fib(n):
  if n <= 1:
      return n
  return fib(n - 1) + fib(n - 2)

print(fib(10))
```)


#codly.new(number-enabled: false, header: [ Hello, world! ], footer: [ Goodbye, world! ], ```py
def fib(n):
  if n <= 1:
      return n
  return fib(n - 1) + fib(n - 2)

print(fib(10))
```)
